import torch
from torch import nn

class FCNet(torch.nn.Module):
    '''
    The MLP class.

    Args: 
        input_dim (int): number of landmarks/joints/velocities.
        output_dim (int): number of electrodes.
        hidden_layer_dim (int or list): Passing an integer will make each hidden layer the exact same dimensionality, passing a list allows you to make each hidden layer a different size.
        add_relu (bool): this gives you the option to add a relu layer at the end of the network. Since we're predicting non-negative firing rates, default is set to True.
    '''
    def __init__(self, input_dim, output_dim, num_layers, hidden_layer_dim, add_relu = True):
        super(FCNet, self).__init__()
        self.name = 'Multi-Layer Perceptron'
        self.net = nn.ModuleList()
        assert num_layers >= 2
        self.num_layers = num_layers
        self.hidden_layer_dim = hidden_layer_dim

        if type(hidden_layer_dim == int):
            # input layer
            self.net.append(nn.Linear(input_dim, hidden_layer_dim))
            self.net.append(nn.ReLU())
            # hidden layers
            for i in range(num_layers-2):
                self.net.append(nn.Linear(hidden_layer_dim, hidden_layer_dim))
                self.net.append(nn.ReLU())
            # output layer
            self.net.append(nn.Linear(hidden_layer_dim, output_dim))
        
        elif type(hidden_layer_dim == list):
            assert len(hidden_layer_dim) == num_layers-1

            #input to first hidden layer
            self.net.append(nn.Linear(input_dim, hidden_layer_dim[0])) 
            self.net.append(nn.ReLU())

            #hidden layer to hidden layer
            for i in range(len(hidden_layer_dim)-1):
                self.net.append(nn.Linear(hidden_layer_dim[i], hidden_layer_dim[i+1]))
                self.net.append(nn.ReLU())

            # final hidden layer to output
            self.net.append(nn.Linear(hidden_layer_dim[-1], output_dim))

        if add_relu == True:
            self.net.append(nn.ReLU())
    
    def forward(self, x):
        for layer in self.net:
            x = layer(x)
        return(x)


class TempConvNet(torch.nn.Module):
    '''
    The sequence-to-sequence TCN class. 
    
    Args:
        input_dim (int): number of landmarks/joints/velocities.
        output_dim (int): number of electrodes to predict.
        num_readout_layers (int): should always be 1. I considered writing code to allow for more, but never got it to work.
        kernel_size (int): length of the kernel in frames. In other functions, default is set to 5.
        filters_per_conv (int): number of filters per convolutional layer. In other functions, default is set to 2. Note that increasing this value increases the size of the network exponentially.
        add_relu (bool): this gives you the option to add a relu layer at the end of the network. Since we're predicting non-negative firing rates, default is set to True.
        causal (bool): when True, this guarantees the convolutional layers do not violate causality. Padding is changed accordingly.

    *** IMPORTANT ***   
        Note the dimensionality of the input is FxN, where F is the number of features in the input and N is the number of instances. 
        A transposition occurs before the final linear layer is applied to ensure the dimensionality of the output is NxD.
    '''
    def __init__(self, input_dim, output_dim, num_conv_layers, num_readout_layers, kernel_size, filters_per_conv, add_relu = True, causal=True):
        super(TempConvNet, self).__init__()
        self.name = "Temporal CNN"
        self.net = nn.ModuleList()
        self.num_conv_layers = num_conv_layers
        self.num_readout_layers = num_readout_layers
        self.input_dim = input_dim
        self.output_dim = output_dim
        self.kernel_size = kernel_size
        self.causal = causal
        self.add_relu = add_relu
        if self.causal == False:
            self.padding = 'same'
        else:
            self.padding = 0
        
        # 1D convolutional layers
        for i in range(num_conv_layers):
            self.net.append(nn.Conv1d(in_channels = input_dim, out_channels = input_dim*filters_per_conv, \
                                      kernel_size = kernel_size, padding = self.padding))
            self.net.append(nn.ReLU())
            input_dim *= filters_per_conv

        # output layer
        self.net.append(nn.Linear(input_dim, output_dim))
        if num_readout_layers > 1:
            for i in range(num_readout_layers-1):
                self.net.append(nn.ReLU())
                self.net.append(nn.Linear(output_dim, output_dim))
        if add_relu == True:
            self.net.append(nn.ReLU())

    def forward(self, x):
        for i, layer in enumerate(self.net):
            # shape_before = x.shape
            # if (type(layer)==torch.nn.modules.linear.Linear) and (i==(len(self.net)-(2*self.num_readout_layers-(1+int(self.add_relu))))):
            #     x = layer(torch.transpose(x, 1, 2))
            # elif ((type(layer)==torch.nn.modules.conv.Conv1d) and (self.causal == True)):
            #     x = layer(x)
            #     x = x[:, :, :-layer.padding[0]]
            # else:
            #     x = layer(x)
            # shape_after = x.shape
            if (type(layer)==torch.nn.modules.linear.Linear):
                x = layer(torch.transpose(x, 1, 2))
            elif ((type(layer)==torch.nn.modules.conv.Conv1d) and (self.causal == True)):
                x = torch.nn.functional.pad(x, (0, 4), mode='constant', value=0)
                x = layer(x)
            else:
                x = layer(x)
            # print('Shape before: {}, shape after: {}'.format(shape_before, shape_after))
        return(x)
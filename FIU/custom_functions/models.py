import torch
from torch import nn

class FCNet(torch.nn.Module):
    def __init__(self, input_dim, output_dim, num_layers, hidden_layer_dim, add_relu = False):
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
            if add_relu == True:
                self.net.append(nn.ReLU())
        
        elif type(hidden_layer_dim == list):
            assert len(hidden_layer_dim) == num_layers-1

            self.net.append(nn.Linear(input_dim, hidden_layer_dim[0]))
            self.net.append(nn.ReLU())
            for i in range(len(hidden_layer_dim)-1):
                self.net.append(nn.Linear(hidden_layer_dim[i], hidden_layer_dim[i+1]))
                self.net.append(nn.ReLU())
            self.net.append(nn.Linear(hidden_layer_dim[-1], output_dim))
    
    def forward(self, x):
        for layer in self.net:
            x = layer(x)
        return(x)


class TempConvNet(torch.nn.Module):
    def __init__(self, input_dim, output_dim, num_conv_layers, num_readout_layers, kernel_size, filters_per_conv, add_relu = False, causal=False):
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
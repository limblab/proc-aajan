function [ AP ] = return_AP_Izad_currents_in( inputCurrents, Vext  )

%INPUT:     inputCurrents:  A vector with elements equal to the number of
%                           contacts being used in the electrode. Each
%                           value is the current in mA.
%           Vext:           The voltage along each axon from each template
%                           1mA input

% OUTPUT:   activation:     an array with elements equal to the number of
%                           fibers. Non-zero if an activation happened


% Loop which incorporates each contact current into the final voltage field
% that an axon is experiencing
final_axon_voltage = inputCurrents(1).*Vext(:,:,1);
for i = 2:length(inputCurrents)
    final_axon_voltage = final_axon_voltage + inputCurrents(i).*Vext(:,:,i);
end

%2nd value is PW is us
%factor of 1000 is to make it in mV
[AP] = Matlab_Izad_2021(final_axon_voltage.*-1000, 50);

end

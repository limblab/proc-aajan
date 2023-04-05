%creating base axon files (V map at nodes) for stim through each
%individual contact
NerveNameString = 'M19T1_Encap';
[fasciclesstart, allaxons] = GenerateNervePopulation(NerveNameString);
for C = 1:15
    [fasciclesfinal, allaxons] = GenerateAxonNodeVoltages(NerveNameString, fasciclesstart, allaxons, [C, 1]);
    axondata.fasciclesfinal = fasciclesfinal;
    axondata.allaxons = allaxons;
    save([NerveNameString '_axondata_C' num2str(C) '_pos1mA.mat'],'axondata')
end

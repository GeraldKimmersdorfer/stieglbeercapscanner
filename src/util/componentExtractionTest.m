% This file tests the self implemented version of the Component-Labeling
% Algorithm (componentExtraction) against the implemented version of the
% image processing toolbox. All the matrices to test need to be stored in
% componentExtraction.mat
% @author: Gerald Kimmersdorfer

data = matfile("C:\Users\Vorto\Documents\evdb\testbilder\util test\componentExtraction.mat");
%save("C:\Users\Vorto\Documents\evdb\testbilder\util test\componentExtraction.mat",'ceTest1','ceTest2')

props = properties(data);
for iprop = 2:length(props)
    thisprop = props{iprop};
    testM = data.(thisprop);
    
    tic;
    [L,components] = componentExtraction(testM);
    t1 = toc; tic;
    [L2,num] = bwlabel(testM);
    t2 = toc;
    
    assert(num == length(components), 'same amount of components need to be found');
    assert(max(max(L)) == length(components), 'max number in L must be equal to component amount');
    
    disp(strcat('Test ', num2str(iprop - 1), ' succeeded wit a time difference of ', num2str(t1-t2), ' seconds in execution.'));
    
    %uncomment to show colored component matrix
    coloredLabels = label2rgb (L, 'hsv', 'k', 'shuffle'); % pseudo random color labels
    imshow(coloredLabels);
    
    %uncomment to show component detail info
    Component.debugInfo(components);
end
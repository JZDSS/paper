d = dir('Y:\database\BP4D-training');
d(1:2) = [];
for i = 1:numel(d)
    for j = 1:8
        curr = fullfile('Y:\database\BP4D-training',d(i).name,['T' num2str(j)]);
        f = dir(fullfile(curr,'*.jpg'));
        mkdir(fullfile(curr,'shape_norm'));
        for k = 1:numel(f)
            copyfile(fullfile(curr,f(k).name),fullfile(curr,'shape_norm',f(k).name));
        end
    end
end
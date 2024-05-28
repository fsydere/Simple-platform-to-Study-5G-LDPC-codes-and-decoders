clear;

% Input Parameters
K = 8448;
N = 10368;
M = N-K;
code_rate = K/N;
puncturing = true; % true or false
puncturing_special = false;
puncturing_size_special = 10;

[ldpc_param] = nr15_fec_ldpc_param_init(K,code_rate);
[BG_Row,BG_Col] = size(ldpc_param.H_BG);

puncturing_size = round(K/(ldpc_param.Z_c*code_rate));

if(puncturing && ~puncturing_special)
    if(puncturing_size*ldpc_param.Z_c ~= K/code_rate)
        error("Puncturing size is invalid change the code rate and TRY again. Remark: puncturing_size*ldpc_param.Z_c == K*code_rate");
    end
end

% Folder Names
AList_file_name = ['SpecialAlist/', 'BG',num2str(ldpc_param.BG_sel),'_','iLS',num2str(ldpc_param.iLS),'_',num2str(N),'_',num2str(K),'.alist'];

%%  Alist Format Generator
fileID = fopen(AList_file_name, "w+");

% VN CN
% Puncturing var kesintiye uğrayacak onu hesaba katmalı 2 tarafta
fprintf(fileID, "%s\n",(num2str(N) + " " + num2str(M)));

% dmax_CN dmax_VN
fprintf(fileID, "%s\n",(num2str(max(ldpc_param.H_row(1:M,1)))) + " " + num2str(max(ldpc_param.H_col(:,1))));

% d_CN
% [row,col] = size(ldpc_param.H_row(:,1));
s = "";
for size = 1:M
    if(size == M)
        s = s + num2str(ldpc_param.H_row(size,1));
    else
        s = s + num2str(ldpc_param.H_row(size,1)) + " ";
    end
end
fprintf(fileID, "%s\n",s);
clear size;

% d_VN
% [row,col] = size(ldpc_param.H_col)
s = "";
for size = 1:N
    if(size == N)
        s = s + num2str(ldpc_param.H_col(size,1));
    else
        s = s + num2str(ldpc_param.H_col(size,1)) + " ";
    end
end
fprintf(fileID, "%s\n",s);
clear size;

% CN to VN (first VN id is 1)
% [row,col] = size(ldpc_param.H_row(:,1));
for size = 1:M
    % if (size == M)
    %     fprintf(fileID, "%s",num2str(ldpc_param.H_row(size,(2:1+ldpc_param.H_row(size,1)))));
    % else
        fprintf(fileID, "%s\n",num2str(ldpc_param.H_row(size,(2:1+ldpc_param.H_row(size,1)))));
    % end
end
% fprintf(fileID, "\n");
clear size;

% VN to CN (first CN id is 1)
[row,col] = size(ldpc_param.H_col(:,1));
for size = 1:N
    if(size == N)
        fprintf(fileID, "%s",num2str(ldpc_param.H_col(size,(2:1+ldpc_param.H_col(size,1)))));
    else
        fprintf(fileID, "%s\n",num2str(ldpc_param.H_col(size,(2:1+ldpc_param.H_col(size,1)))));
    end
end
% fprintf(fileID, "\n");
clear size;

fclose(fileID);

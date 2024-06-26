clear;

% Input Parameters
K = 3840;
N = 6528;
M = N-K;
code_rate = K/N;
puncturing = true; % true or false
puncturing_special = false;
puncturing_size_special = 10;

[ldpc_param] = nr15_fec_ldpc_param_init(K,code_rate);
[BG_Row,BG_Col] = size(ldpc_param.H_BG);

% Folder Names
AList_file_name = ['Alist Files/', 'BG',num2str(ldpc_param.BG_sel),'_','iLS',num2str(ldpc_param.iLS),'_','Z_c',num2str(ldpc_param.Z_c),'_','K',num2str(K),'_','N',num2str(N),'.alist'];
QC_file_name = ['QC Files/', 'BG',num2str(ldpc_param.BG_sel),'_','iLS',num2str(ldpc_param.iLS),'_','Z_c',num2str(ldpc_param.Z_c),'_','K',num2str(K),'_','N',num2str(N),'.qc'];

% Re-arranging H_col
check = ldpc_param.H_col <= M;
ldpc_param.H_col = ldpc_param.H_col .* check;
[row,col] = size(ldpc_param.H_col);
for r = 1:row
    counter = 0;
    for c = 2:col
        if(ldpc_param.H_col(r,c) > 0)
            counter = counter +1;
        end
    end
    ldpc_param.H_col(r,1) = counter;
end

%%  Alist Format Generator
fileID = fopen(AList_file_name, "w+");

% VN CN
fprintf(fileID, "%s\n",(num2str(N) + " " + num2str(M)));

% dmax_CN dmax_VN
fprintf(fileID, "%s\n",(num2str(max(ldpc_param.H_row(1:M,1)))) + " " + num2str(max(ldpc_param.H_col(:,1))));

% d_CN
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
for size = 1:M
    fprintf(fileID, "%s\n",num2str(ldpc_param.H_row(size,(2:1+ldpc_param.H_row(size,1)))));
end
clear size;

% VN to CN (first CN id is 1)
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
%% QC File Generation

puncturing_size = round(K/(ldpc_param.Z_c*code_rate));

if(puncturing && ~puncturing_special)
    if(puncturing_size*ldpc_param.Z_c ~= K/code_rate)
        error("Puncturing size is invalid change the code rate and TRY again. Remark: puncturing_size*ldpc_param.Z_c == K*code_rate");
    end
end

fileID_QC = fopen(QC_file_name, "w+");
fprintf(fileID_QC, "%s\n",(num2str(BG_Col) + " " + num2str(BG_Row) + " " + num2str(ldpc_param.Z_c)));

for row=1:BG_Row
    for col = 1:BG_Col
        if(col == BG_Col)
            fprintf(fileID_QC, "%s\n",num2str(ldpc_param.H_BG(row,col)));
        else
            fprintf(fileID_QC, "%s ",num2str(ldpc_param.H_BG(row,col)));
        end
    end
end

if(puncturing && ~puncturing_special)
    for col=1:BG_Col
        if(col <= puncturing_size)
            if(col == BG_Col)
                fprintf(fileID_QC, "%s",num2str(1));
            else
                fprintf(fileID_QC, "%s ",num2str(1));
            end
            
        else
            if(col == BG_Col)
                fprintf(fileID_QC, "%s",num2str(0));
            else
                fprintf(fileID_QC, "%s ",num2str(0));
            end
        end
    end
elseif(puncturing && puncturing_special)
    for col=1:BG_Col
        if(col <= puncturing_size_special)
            if(col == BG_Col)
                fprintf(fileID_QC, "%s",num2str(1));
            else
                fprintf(fileID_QC, "%s ",num2str(1));
            end
            
        else
            if(col == BG_Col)
                fprintf(fileID_QC, "%s",num2str(0));
            else
                fprintf(fileID_QC, "%s ",num2str(0));
            end
        end
    end
end

fclose(fileID_QC);
display(['BG',num2str(ldpc_param.BG_sel),'_','iLS',num2str(ldpc_param.iLS),'_','Z_c',num2str(ldpc_param.Z_c),'_','K',num2str(K),'_','N',num2str(N),' DONE']);


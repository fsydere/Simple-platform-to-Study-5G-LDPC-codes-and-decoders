clear;

% Input Parameters
K = 8448;
code_rate = 2/3;
puncturing = true; % true or false

[ldpc_param] = nr15_fec_ldpc_param_init(K,code_rate);
[BG_Row,BG_Col] = size(ldpc_param.H_BG);

% Folder Names
AList_file_name = ['Alist Files/', 'BG',num2str(ldpc_param.BG_sel),'_','iLS',num2str(ldpc_param.iLS),'_',num2str(ldpc_param.E),'_',num2str(ldpc_param.K),'.alist'];
QC_file_name = ['QC Files/', 'BG',num2str(ldpc_param.BG_sel),'_','iLS',num2str(ldpc_param.iLS),'_',num2str(ldpc_param.E),'_',num2str(ldpc_param.K),'.qc'];

%%  Alist Format Generator
fileID = fopen(AList_file_name, "w+");

% VN CN
fprintf(fileID, "%s\n",(num2str(BG_Col) + " " + num2str(BG_Row)));

% dmax_VN dmax_CN
fprintf(fileID, "%s\n",(num2str(max(ldpc_param.H_col(:,1))) + " " + num2str(max(ldpc_param.H_row(:,1)))));


% d_VN
[row,col] = size(ldpc_param.H_col);
s = "";
for size = 1:row
    if(size == row)
        s = s + num2str(ldpc_param.H_col(size,1));
    else
        s = s + num2str(ldpc_param.H_col(size,1)) + " ";
    end
end
fprintf(fileID, "%s\n",s);
clear size;

% d_CN
[row,col] = size(ldpc_param.H_row(:,1));
s = "";
for size = 1:row
    if(size == row)
        s = s + num2str(ldpc_param.H_row(size,1));
    else
        s = s + num2str(ldpc_param.H_row(size,1)) + " ";
    end
end
fprintf(fileID, "%s\n",s);
clear size;

% VN to CN (first CN id is 1)
[row,col] = size(ldpc_param.H_col(:,1));
for size = 1:row
    fprintf(fileID, "%s\n",num2str(ldpc_param.H_col(size,(2:1+ldpc_param.H_col(size,1)))));
end
% fprintf(fileID, "\n");
clear size;

% CN to VN (first VN id is 1)
[row,col] = size(ldpc_param.H_row(:,1));
for size = 1:row
    if (size == row)
        fprintf(fileID, "%s",num2str(ldpc_param.H_row(size,(2:1+ldpc_param.H_row(size,1)))));
    else
        fprintf(fileID, "%s\n",num2str(ldpc_param.H_row(size,(2:1+ldpc_param.H_row(size,1)))));
    end
end
% fprintf(fileID, "\n");
clear size;
fclose(fileID);
%% QC File Generation

if(puncturing)
    puncturing_size = round(K/(ldpc_param.Z_c*code_rate));
    if(puncturing_size*ldpc_param.Z_c ~= K/code_rate)
        error("puncturing size is invalid change the code rate and TRY again. Remark: puncturing_size*ldpc_param.Z_c == K*code_rate");
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
if(puncturing)
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
end

fclose(fileID_QC);

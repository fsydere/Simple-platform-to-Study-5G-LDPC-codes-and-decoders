clear;

B = 8448;
code_rate = .88;

[ldpc_param] = nr15_fec_ldpc_param_init(B,code_rate);

% Alist Format Generator
AList_file_name = ['BG',num2str(ldpc_param.BG_sel),'_','iLS',num2str(ldpc_param.iLS),'_',num2str(ldpc_param.E),'_',num2str(ldpc_param.B),'.alist'];
fileID = fopen(AList_file_name, "w+");
[BG_Row,BG_Col] = size(ldpc_param.H_BG);

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
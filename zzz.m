clear;clc
%定义 button
plotbutton=uicontrol('style','pushbutton',...
'string','Run',...
'fontsize',12,...
'position',[100,400,50,20],...
'callback','run=1;');
erasebutton=uicontrol('style','pushbutton',...
'string','Stop',...
'fontsize',12,...
'position',[300,400,50,20],...
'callback','freeze=1;');
number=uicontrol('style','text',...
'string','1',...
'fontsize',12,...
'position',[20,400,50,20]);
z=zeros(160,240);
cells=z;%元胞矩阵
weith=160;length=240;
x0=20;y0=120;%最佳出逃位置
peoplemidu=0.6;%人员密度
%危险度
z(1:20,1:100)=0;
z(1:20,140:240)=0;%障碍区

%初始化函数图像
xpf1=zeros(1,128)
xpf2=zeros(1,128)
%为出口赋值
for i = 1:20
    for j = 100:140
        pd(i,j)=i;
    end
end

for  i=21:158
    for j=3:238
        if(j <= 100)
            pd(i,j)=sqrt((i-20)^2+(j-100)^2);
        elseif(j >=140)
            pd(i,j)=sqrt((i-20)^2+(j-140)^2);
        else
            d(i,j)=i-20;
        end
        pd(i,j)=sqrt((i-1)^2+(j-120)^2);
    end
end
%%%%初始化选择矩阵
        for i=21:158
            for j= 3:238
                choice{i,j}=[0 0]; %为什么默认是左上角？
            end
        end
%如果已经到了出口，那么默认往前走
for i = 1:20
    for j = 100:140
        choice{i,j}=[0 0];
    end
end
%%%%初始化人群
cells(1:20,100:140)=1;%留出出口
cells(21:158,3:238)=1;
for  i=22:157
    for j=4:237
        if(sqrt((i-20)^2+(j-120)^2) < 100)
            if(rand<=peoplemidu)
                 cells(i,j)=0.25; %此处有人，原来是白人，现在改成了灰人
                 pv(i,j)=1; %？？？？？？pv做什么的？
                 choice{i,j}=[i j]; %默认该人倾向于选择原点——空点选择不可能的点，有人的点选择留在原地
            end
        end
    end
end



imh = imshow(cat(3,cells,cells,cells)); %
axis equal
axis tight
stop= 0; 
run = 0; 
freeze = 0; 
%%%%开始逃生 



while (stop==0)
	if(run==1)  %按下run键
        %判断每个人该如何逃生？
        for i = 2:20
            for j = 100:140
                if(cells(i,j)==0.25 )
                    choice{i,j} =[i-1 j];
                end
            end
        end
        for i=21:158  
            for j=3:238
                %disp(74);
                if(cells(i,j)==0.25) %如果有人
                    if (j>=101 && j<=139 && i==21)  
                        choice{i,j}=[i-1 j]; %可以直接出去了
                        cells(i,j) = 1;
                    else
                        [newi,newj]=findnew(i,j,pd);  %找到选择位置
                         if(pd(i,j)>pd(newi,newj)) %新位置风险更小
                             flag = same(i,j,newi,newj,choice);
                            if(flag)   %如果新的点没人
                                choice{i,j} = [newi newj];
                            else
                                choice{i,j}=[i j]; %一旦和别人想要的选择冲突，留在原地
                            end
                        end
                        
                        if (pd(i,j)==pd(newi,newj)) %如果两处风险一样
                             flag = same(i,j,newi,newj,choice);
                            if(flag) %如果新的点没人
                                if(rand>=0.25)   %50%的概率选择新位置
                                    choice{i,j}=[newi newj];
                                else
                                    choice{i,j}=[i j];
                                end
                              else
                                  choice{i,j}=[i j];    %如果和别人冲突了，而且风险一样，那就留在原地
                            end
                        end
                         
                         if (pd(i,j)<pd(newi,newj)) %如果新位置风险更大
                             flag = same(i,j,newi,newj,choice);
                             disp(flag);
                             disp(['line110 flag= ' num2str(flag)]);
                             break;
                              if(flag) %如果没和别人冲突
                                if(rand>0.2) %0.8的概率留在原地
                                    choice{i,j}=[i j];
                                else
                                    choice{i,j}=[newi newj]; %0.2的概率跳过去
                                end
                              else
                                  choice{i,j}=[i j]; %和别人冲突，风险还大，我跳了干嘛？
                             end
                          end
                    end
                end
            end
        end
        
        %根据choice，
        for i = 2:20
            for j = 100:140
                if(choice{i,j} ~= [0 0]) %如果不是空白点
                    m=choice{i,j};
                    ii=m(1);jj=m(2);
                    cells(ii,jj)=0.25;   %新位置
                    cells(i,j)=1;
                end
            end
        end
        %如果此时的下一跳地址
        for i=21:158   
            for j=3:238
                if(choice{i,j} ~= [0 0]) %如果不是空白点
                    m=choice{i,j};
                    ii=m(1);jj=m(2);
                    cells(ii,jj)=0.25;   %新位置
                    cells(i,j)=1;
                end
            end
        end
        
        for i = 2:20
            for j = 100:140
                if(cells(i,j) == 1) %如果不是空白点
                    choice{i,j} = [0 0];
                else
                    choice{i,j} = [i j];
                end
            end
        end
        %把choice进行置位？？？
        for i=21:158
            for j=3:238
                if(cells(i,j)==1)
                    choice{i,j}=[0 0];
                else
                    choice{i,j}=[i j];
                end
            end
        end
        z=cells(:,:);
        for i=1:160
            for j = 1:240
                if(z(i,j)==0.25)
                    z(i,j)=1;
                end
            end
        end
        pause(0.1);
        
        set(imh, 'cdata', cat(3,cells,z,z) )
        stepnumber = 1 + str2num(get(number,'string'));

        for j=100:140
            if(cells(2,j)==0.25) 
                xpf1(stepnumber) = xpf1(stepnumber)+1;
            end
            if(cells(20,j)==0.25) 
                xpf2(stepnumber) = xpf1(stepnumber)+1;
            end
        end
        set(number,'string',num2str(stepnumber))
    end
    
    
    
    if (freeze==1)
        run = 0;
        freeze = 0;
        disp(xpf1);
        disp(xpf2);
        x=1:1:128;
        xpf1(1,22:82) = xpf1(1,22:82) - 2.4;
        xpf2(1,20:82) = xpf2(1,20:82) + 5.9;
        y=zeros(1,128);
        y(1,:)=23.6;
        z=zeros(1,128);
        z(1,:)=30.9;
       plot(x,xpf1,'r',x,xpf2,'b',x,y,'k',x,z,'k','LineWidth',3);%p%E
       text(1.2,25,'E=23.8');
       text(1.2,32.1,'p=30.9');
       legend('E','p');
    end 
    drawnow 
    
   
end

%%%%  判断是否已经选择重复
function rt=same(i,j,newi,newj,choice)
    rt=1;
    %disp(155)
    k = 0;
    for m = i-2:i+2
        for n = j-2:j+2
            if(m == i && n == j)
                continue;
            elseif(m <= 21 || m >= 158 || n <= 3 || n >= 238)
                continue;
            end
            if(k == 24)
                rt = 1;
                break;
            end
            %disp(['m= ' num2str(m) ' n= ' num2str(n) 'choice{m,n}= '  num2str(choice{m,n}) ' [newi newj]= ' num2str([newi newj])]);
            if([newi newj]==choice{m,n})   
                
                rt=0;%
                break; %disp(['i= ' num2str(i) ' j= ' num2str(j) 'choice{i,j}= ' num2str(choice{i,j}) ' [newi newj]= ' num2str([newi newj]) ' k= ' num2str(k)]);       
            end
            k = k+1;
        end
    end
end

%%%%%%%  寻找新位置
function [newi,newj]=findnew(i,j,pd)
    if(i==158)
        newi = i-1;
        newj = j;
    end
    if(j == 3)
        newi = i;
        newj = j+1;
    end
    if(j == 238)
        newi = i;
        newj = j-1;
    end
    if(i == 21 && j <= 100)
        newi = i;
        newj = j+1;
    end
    if(i == 21 && j >= 140)
        newi = i;
        newj = j-1;
    end
    
    if(i>=22&&i<=157&&j>=4&&j<=237)
        a=[pd(i-1,j) pd(i-1,j+1) pd(i-1,j-1) pd(i,j-1) pd(i,j+1) pd(i+1,j-1) pd(i+1,j) pd(i+1,j+1)];    %找到危害最小的地方
        [m,n]=min(a);
        switch n
            case 1
                newi=i-1;newj=j;
            case 2
                 newi=i-1;newj=j+1;      
            case 3
                 newi=i-1;newj=j-1;
            case 4
                 newi=i;newj=j-1;
            case 5 
                newi=i;newj=j+1;
            case 6
                 newi=i+1;newj=j-1;      
            case 7
                 newi=i+1;newj=j;
            otherwise
                 newi=i+1;newj=j+1;
        end
    end
end

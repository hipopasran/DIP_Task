clear, close all

% ���� �������� ������������ ����������
Name_Original = 'battery4.jpg';

% ������ ������������� �����������
Original=imread(Name_Original);
imshow(Original),title('������������ �����������');

% �������������� � ����������� �����������
Or=rgb2gray(Original);

% ���������� ������� ������
h=fspecial('gaussian');
grayImage = imfilter(Or,h,'replicate');

% ��������� ��������� �����������
binaryImage= (grayImage >0) & (grayImage <80) ;

% ��������� ����� ����������
maskedImage = grayImage; % Initialize.
maskedImage(~binaryImage) = 0;

% ��������� ����� 
bk=grayImage-maskedImage;

% ���������� ����������� ���� '���� �����'
se=strel('disk', 3);
I=imsubtract(imadd(bk, imtophat(bk, se)), imbothat(bk, se));

% ��������� ���������� � ����� 3
I=medfilt2(bk, [3, 3]);

% ����������� ������ ������� ������
BWs=edge(I, 'Sobel',(graythresh(I))*0.035);

% ����������� �����������
se90=strel('line', 3, 90);
se0=strel('line', 3, 0);
BWsdil=imdilate(BWs, [se90 se0]);

% �������� ������ ��������
BWsdil = bwareaopen(BWsdil,1);

% ��������������� �������� �����������
se = strel('disk',15);
BWsdil = imclose(BWsdil,se);

% ���������� ��� 
BWdfill = imfill(BWsdil,'holes');
BWdfill=bwfill(BWdfill,'holes');

% ���������� ��������, ��������� � �������� ����������
BWnobord=imclearborder(BWdfill);

% ���������(������) �����������
seD=strel('diamond',3);
BWfinal=imerode(BWnobord, seD);
BWfinal=imerode(BWfinal, seD);
BWfinal=imerode(BWfinal, seD);

% ��������������� �������� �����������
I2 = imopen(BWfinal,strel('disk',30));

% �������� ���������� ����������� � ����� ����
figure, imshow(Original), title(['��������� ���������']);;

% ������� ������ �� �����������
[B,L] = bwboundaries(I2,'noholes');
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

% ������� ������������� ��������� ��������
stats = regionprops(L,'Area','Centroid');

% ����������� ��� ���������� ���� Tablet
threshold = 0.85;

% �������� �������� ��� �������� ���������� � �������� �� �����������
 AA='AA';
 AAA='AAA';
 Tablet='Tablet';
 Count_AA=0;
 Count_AAA=0;
 Count_Tablet=0;

% ����� �� �������� ��������
for k = 1:length(B)

  % ��������� ��������� ��������� ��� ������� 'k'
  boundary = B{k};

  % ���������� ��������� �������
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % ������ ������� ������� 'k'
  area = stats(k).Area;
  
  % ������� ������� ����������
  metric = 4*pi*area/perimeter^2;
  

  % ��������� ����������� �� �����������
  if metric > threshold
    text(boundary(1,2)-35,boundary(1,1)+13,Tablet,'Color','black',...
       'FontSize',20,'FontWeight','bold');
   Count_Tablet=Count_Tablet+1;
  end
  if(area>=100000)
  text(boundary(1,2)-35,boundary(1,1)+13,AA,'Color','black',...
       'FontSize',20,'FontWeight','bold');
   Count_AA=Count_AA+1;
  elseif (area>= 85000 & area<100000)
  text(boundary(1,2)-35,boundary(1,1)+13,AAA,'Color','black',...
       'FontSize',20,'FontWeight','bold');
   Count_AAA=Count_AAA+1;
  end;
  
end

% ������ ���������� � ������� �� �����������
legend(['������� ��������: ' num2str(length(B))],['AA - ' num2str(Count_AA) ' ��'],['AAA - ' num2str(Count_AAA) ' ��'],['Tablet - ' num2str(Count_Tablet) ' ��'],'Location','southwest');

% ���������� ���������� ���������� � ������������
F = getframe(gca);
imMarked = frame2im(F);
imwrite(imMarked,['segmented_' Name_Original]);
   


clear, close all

% Ввод названия оригинаьного изоражения
Name_Original = 'battery4.jpg';

% Чтение оригинального ихображения
Original=imread(Name_Original);
imshow(Original),title('Оригинальное изображение');

% Преобразование в полутоновое изображение
Or=rgb2gray(Original);

% Применение фильтра Гаусса
h=fspecial('gaussian');
grayImage = imfilter(Or,h,'replicate');

% Получение бинарного изображения
binaryImage= (grayImage >0) & (grayImage <80) ;

% Получение маски иображения
maskedImage = grayImage; % Initialize.
maskedImage(~binaryImage) = 0;

% Вычитание маски 
bk=grayImage-maskedImage;

% Выполнение фильттрации типа 'верх шляпы'
se=strel('disk', 3);
I=imsubtract(imadd(bk, imtophat(bk, se)), imbothat(bk, se));

% Медианная фильтрация с ядром 3
I=medfilt2(bk, [3, 3]);

% Определение границ методом Собеля
BWs=edge(I, 'Sobel',(graythresh(I))*0.035);

% Расширенное изображение
se90=strel('line', 3, 90);
se0=strel('line', 3, 0);
BWsdil=imdilate(BWs, [se90 se0]);

% Удаление мелких объектов
BWsdil = bwareaopen(BWsdil,1);

% Морфологическое закрытие изображения
se = strel('disk',15);
BWsdil = imclose(BWsdil,se);

% Заполнение дыр 
BWdfill = imfill(BWsdil,'holes');
BWdfill=bwfill(BWdfill,'holes');

% Подавление структур, связанных с границей изображеия
BWnobord=imclearborder(BWdfill);

% Уточнение(эрозия) изображения
seD=strel('diamond',3);
BWfinal=imerode(BWnobord, seD);
BWfinal=imerode(BWfinal, seD);
BWfinal=imerode(BWfinal, seD);

% Морфологическое открытие изображения
I2 = imopen(BWfinal,strel('disk',30));

% Открытие финального изображения в новом окне
figure, imshow(Original), title(['Финальный результат']);;

% Обводка границ на изображении
[B,L] = bwboundaries(I2,'noholes');
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

% Подсчет характеристик найденных объектов
stats = regionprops(L,'Area','Centroid');

% Погрещность для определени вида Tablet
threshold = 0.85;

% Создание объектов для подсчета статистики и отметках на изображении
 AA='AA';
 AAA='AAA';
 Tablet='Tablet';
 Count_AA=0;
 Count_AAA=0;
 Count_Tablet=0;

% Обход по границам объектов
for k = 1:length(B)

  % Получения граничных координат для объекта 'k'
  boundary = B{k};

  % Вычисление периметра объекта
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % Расчет площади объекта 'k'
  area = stats(k).Area;
  
  % Подсчет метрики округлости
  metric = 4*pi*area/perimeter^2;
  

  % Выделение результатов на изображение
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

% Запись статистики в легенду на изображении
legend(['Найдено батареек: ' num2str(length(B))],['AA - ' num2str(Count_AA) ' шт'],['AAA - ' num2str(Count_AAA) ' шт'],['Tablet - ' num2str(Count_Tablet) ' шт'],'Location','southwest');

% Сохранение финального изоражения с маркировками
F = getframe(gca);
imMarked = frame2im(F);
imwrite(imMarked,['segmented_' Name_Original]);
   


1. Создаем файл спрайта (например, icons.svg)

В этом файле не должно быть тегов <html>, <body> или нескольких тегов <svg>. Должен быть один корень <svg>, внутри которого лежат твои иконки, обернутые в <symbol>. Каждому символу даем уникальный id.

Файл icons.svg

<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
    <symbol id="icon-genetic-data" viewBox="0 0 1024 1024">
        <path d="M512 960c-92.8 0-160-200-160-448S419.2 64 512 64s160 200 160 448-67.2 448-160 448z m0-32c65.6 0 128-185.6 128-416S577.6 96 512 96s-128 185.6-128 416 62.4 416 128 416z" fill="currentColor" />
        <path d="M124.8 736c-48-80 92.8-238.4 307.2-363.2S852.8 208 899.2 288 806.4 526.4 592 651.2 171.2 816 124.8 736z m27.2-16c33.6 57.6 225.6 17.6 424-97.6S905.6 361.6 872 304 646.4 286.4 448 401.6 118.4 662.4 152 720z" fill="currentColor" />
        <path d="M512 592c-44.8 0-80-35.2-80-80s35.2-80 80-80 80 35.2 80 80-35.2 80-80 80z" fill="#2F4BFF" />
    </symbol>

    <symbol id="icon-chip" viewBox="0 0 1024 1024">
        <path d="M625.6 516.8l19.2 81.6..." fill="currentColor" />
    </symbol>
</svg>

Совет: Замени жестко прописанные fill="#050D42" на fill="currentColor", тогда ты сможешь менять цвет иконок прямо из CSS.

2. Используем в основном файле (например, index.html)

Чтобы подключить иконку из внешнего файла, в href нужно указать путь к файлу, а затем через решетку # — id иконки.

Файл index.html:

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Мой проект</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <h1>Использование иконок</h1>

    <svg class="icon blue-icon">
        <use href="icons.svg#icon-genetic-data"></use>
    </svg>

    <svg class="icon">
        <use href="icons.svg#icon-chip"></use>
    </svg>

    <script src="script.js"></script>
</body>
</html>

3. Настраиваем CSS

Чтобы иконки отображались корректно, им нужно задать размеры (по умолчанию они могут быть 0x0 или огромными).

Файл style.css:

.icon {
width: 50px;
height: 50px;
display: inline-block;
/* Если в SVG стоит fill="currentColor", цвет будет наследоваться отсюда */
color: #050D42;
}

.blue-icon {
color: #2F4BFF;
width: 100px;
height: 100px;
}


Расширение файла: Лучше использовать .svg для файла со списком иконок.

Структура спрайта: Один внешний <svg>, внутри много <symbol>.

Путь в use: Обязательно пишем имя_файла.svg#id_иконки. Если написать просто #id, браузер будет искать иконку внутри этого же HTML-файла.

Никаких <link href="icon.html">: Иконки подтягиваются самим тегом <use> по мере надобности.
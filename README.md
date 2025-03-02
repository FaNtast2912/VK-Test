# VK Reviews App

<img src="https://raw.githubusercontent.com/FaNtast2912/VK-Test/main/Demo/Test_Demo.gif" alt="ImageFeed Demo" width="200">  
*Демонстрация скролла ленты с отзывами.*   

## Описание проекта

Это тестовое приложение для VK, предназначенное для отображения списка отзывов. В проекте использованы: UIKit, URLSession, архитектура MVVM, CALayer и верстка на фреймах. Основная цель приложения — демонстрация навыков тестирования производительности с помощью Instruments, структурирования кода, работы с UITableView и управления памятью.

## Функциональные улучшения

### 1. Добавлен класс для декодирования `SnakeCaseJSONDecoder`

Реализовал декодер, автоматически преобразующий `snake_case` в `camelCase`. Это упростило работу с JSON и сократило необходимость объявлять `CodingKeys`.

---

### 2. Добавлено отображение имени комментатора и рейтинга

Теперь в отзывах отображается имя автора и его рейтинг, что делает список отзывов более информативным.

---

### 3. Устранены утечки памяти

Провел анализ с помощью Instruments (Leaks), выявил и устранил retain cycle, улучшив управление памятью.

---

### 4. Добавлены изображения аватаров комментаторов

Реализовал загрузку и кэширование аватаров, чтобы сделать интерфейс более удобным и избежать лишних сетевых запросов.

---

### 5. Добавлена загрузка в фоновый поток (ранее была ошибка)

Исправил ошибку, из-за которой сетевые запросы выполнялись в главном потоке. Теперь загрузка данных происходит в фоновом потоке, а обновление UI — в главном.

---

### 6. Добавлен счетчик отзывов (обработана ситуация, когда отзывов больше, чем обещал сервер)

Реализовал дополнительную проверку количества отзывов и корректное отображение данных, если их пришло больше, чем ожидалось.

---

### 7. Добавлен `LoadingIndicator`

Добавил индикатор загрузки, чтобы пользователь видел, что данные еще загружаются.

---

### 8. Добавлен класс для асинхронной загрузки изображений

Реализовал загрузку изображений через `URLSession`, добавил кэширование и многопоточность с помощью GCD для оптимизации производительности.

---

### 9. Добавлена загрузка фото в отображение отзыва

Теперь отзывы могут содержать изображения, что делает их более наглядными.

---

### 10. Добавлено частичное обновление таблицы `performBatchUpdates` вместо `reloadData`

Использовал `performBatchUpdates` для обновления только изменившихся ячеек, чтобы повысить производительность списка отзывов.

---

## Заключение

Этот проект демонстрирует работу с сетевыми запросами, обработку данных, оптимизацию работы с памятью и улучшение пользовательского интерфейса. Использование Instruments позволило выявить и устранить узкие места, а работа с `UITableView` обеспечила плавную и отзывчивую работу приложения.


## Примеры выполненного задания:

Минимальный вариант|Максимальный вариант|Ячейка количества отзывов
-|-|-
![Минимальный вариант](/Screenshots/1.png) | ![Максимальный вариант](/Screenshots/2.png) | ![Ячейка количества отзывов](/Screenshots/3.png)

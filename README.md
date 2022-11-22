# WMI-Class-Viewer

Используется для поиска и просмотра классов WMI, а так же их свойств и методов на локальном или удаленном компьютере (через RPC) с выводом в таблицу и в формате текста.

> 

# Версия 1.2 
* Вместо постоянного обращения к серверу с запросом отфильтрованного класса для поиска, теперь присутствует формат фильтрации по таблице с уже полученными значениями. В интернете нет реализации фильтрации DataGridView.Visible для powershell, решил путем события TextChanged с фильтрацией уже полученной переменной и повторным заполнением DGV. Так же выполнена фильтрафция по тексту, только для открытого класса.
* Добавлена кнопка просмотра дочерних Namespace, без необходимости находить и открывать Class: __NAMESPACE
* При выборе значения в таблице, есть возможность скопировать его содержимое нажатием правой кнопки мыши.
* Для отображения списка всех методов класса, необходимо в таблице выбрать значение из стобца Methods и нажать Open Method.

![Image alt](https://github.com/Lifailon/WMI-Class-Viewer/blob/rsa/Interface.jpg)

![Image alt](https://github.com/Lifailon/WMI-Class-Viewer/blob/rsa/RDP-On.jpg)



# WMI-Class-Viewer

Используется для поиска и просмотра классов WMI, а так же их свойств и методов на локальном или удаленном компьютере (через RPC) с выводом в таблицу и в формате текста.
Для просмотра (поиска) всех дочерних Namespace откройте Class: __NAMESPACE

# Версия 1.2 
Вместо постоянного обращения к серверу с запросом отфильтрованного класса для поиска, теперь присутствует формат фильтрации по таблице с уже полученными значениями. В интернете нет реализации филтрации DGV.Visible для powershell, решил путем события TextChanged с фильтрацией уже полученной переменной и повторным заполнением DGV.

![Image alt](https://github.com/Lifailon/WMI-Class-Viewer/blob/rsa/Open%20Class%20Namespace.jpg)

![Image alt](https://github.com/Lifailon/WMI-Class-Viewer/blob/rsa/Find%20Namespace.jpg)



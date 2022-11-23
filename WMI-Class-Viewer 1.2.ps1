#region form
$path = "$env:userprofile\Documents\wmi_temp.log"
$Font = "Arial"
$Size = "12"
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "WMI-Class-Viewer"
$main_form.ShowIcon = $false
$main_form.StartPosition = "CenterScreen"
$main_form.Font = "$Font,$Size"
$main_form.ForeColor = "Black"
$main_form.Size = New-Object System.Drawing.Size(1400,910)
$main_form.AutoSize = $true

$GroupBox_key = New-Object System.Windows.Forms.GroupBox
$GroupBox_key.AutoSize = $true
$GroupBox_key.Location = New-Object System.Drawing.Point(10,20)
$GroupBox_key.Size = New-Object System.Drawing.Size(1360,1)

$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Location = New-Object System.Drawing.Point(10,190)
$TabControl.Size = New-Object System.Drawing.Size(1365,650)

$TabPage_table = New-Object System.Windows.Forms.TabPage
$TabPage_table.Text = "Table"
$TabControl.Controls.Add($TabPage_table)

$TabPage_text = New-Object System.Windows.Forms.TabPage
$TabPage_text.Text = "Text"
$TabControl.Controls.Add($TabPage_text)

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(0,2)
$dataGridView.Size = New-Object System.Drawing.Size(1355,567)
$dataGridView.Font = "$Font,10"
$dataGridView.AutoSize = $false
$dataGridView.MultiSelect = $false
$dataGridView.ReadOnly = $true
$TabPage_table.Controls.Add($dataGridView)

$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$ContextMenu.MenuItems.Add("Скопировать",{
$dgv_selected = $dataGridView.SelectedCells.Value
Set-Clipboard $dgv_selected
})
$TabPage_table.ContextMenu = $ContextMenu

$outputBox_Tab_Text = New-Object System.Windows.Forms.TextBox
$outputBox_Tab_Text.Location = New-Object System.Drawing.Point(0,2)
$outputBox_Tab_Text.Size = New-Object System.Drawing.Size(1355,567)
$outputBox_Tab_Text.MultiLine = $True
$TabPage_text.Controls.Add($outputBox_Tab_Text)

$VScrollBar = New-Object System.Windows.Forms.VScrollBar
$outputBox_Tab_Text.Scrollbars = "Vertical"

function SaveFile {
$global:statusLabel.Text = "Сохранение файла"
$SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$SaveFileDialog.Filter = "All Files (*.txt)|*.txt"
$SaveFileDialog.InitialDirectory = "$env:USERPROFILE\desktop\"
$SaveFileDialog.Title = "Выберите файл"
$SaveFileDialog.ShowDialog()
$global:path_out = $SaveFileDialog.FileNames # забрать путь к файлу
$status.Text = "Файл сохранен: $path_out"
}
#endregion

#region key
$Label_srv = New-Object System.Windows.Forms.Label
$Label_srv.Text = "Server:"
$Label_srv.Location = New-Object System.Drawing.Point(8,25)
$Label_srv.AutoSize = $true
$GroupBox_key.Controls.Add($Label_srv)

$outputBox_comp = New-Object System.Windows.Forms.TextBox
$outputBox_comp.Text = "localhost"
$outputBox_comp.Location = New-Object System.Drawing.Point(10,50)
$outputBox_comp.Size = New-Object System.Drawing.Size(250,26)
$outputBox_comp.MultiLine = $True
$GroupBox_key.Controls.Add($outputBox_comp)

$Label_ns = New-Object System.Windows.Forms.Label
$Label_ns.Text = "NameSpace:"
$Label_ns.Location = New-Object System.Drawing.Point(268,25)
$Label_ns.AutoSize = $true
$GroupBox_key.Controls.Add($Label_ns)

$ComboBox_namespace = New-Object System.Windows.Forms.ComboBox
$ComboBox_namespace.DataSource = @("root","root\CIMV2","root\CIMV2\Terminalservices","root\MicrosoftActiveDirectory","root\MicrosoftDNS","root\MicrosoftDFS",`
"root\Microsoft\Windows\DFSN","root\Microsoft\Windows\DFSR","root\Microsoft\Windows\DNS","root\Microsoft\Windows\DHCP","root\Microsoft\Windows\SMB")
$ComboBox_namespace.Location  = New-Object System.Drawing.Point(270,50)
$ComboBox_namespace.Size = New-Object System.Drawing.Size(250,30)
$GroupBox_key.Controls.Add($ComboBox_namespace)

$Label_Search = New-Object System.Windows.Forms.Label
$Label_Search.Text = "Filter Class:"
$Label_Search.Location = New-Object System.Drawing.Point(8,85)
$Label_Search.AutoSize = $true
$GroupBox_key.Controls.Add($Label_Search)

$TextBox_Search = New-Object System.Windows.Forms.TextBox
$TextBox_Search.Location = New-Object System.Drawing.Point(10,110)
$TextBox_Search.Size = New-Object System.Drawing.Size(830,25)
$TextBox_Search.MultiLine = $True
$GroupBox_key.Controls.Add($TextBox_Search)

function main-var {
$global:comp = $outputBox_comp.Text
$global:ns = $ComboBox_namespace.Text
$global:class = $ComboBox_class.Text
}
#endregion

#region view class
$button_view_class = New-Object System.Windows.Forms.Button
$button_view_class.Text = "View Class"
$button_view_class.Location = New-Object System.Drawing.Point(530,49)
$button_view_class.Size = New-Object System.Drawing.Size(150,28)
$GroupBox_key.Controls.Add($button_view_class)

$button_view_class.Add_Click({
$dataGridView.AutoSizeColumnsMode = "Fill"
main-var
$global:out_find_class = @(gwmi -ComputerName $comp -Namespace $ns -List | `
select name,@{Label="Properties"; Expression={$_.properties.name}},@{Label="Methods"; Expression={$_.methods.name}} | sort -Descending Methods)
$count = $out_find_class.count
$status.text = "Class count: $count"
$list = New-Object System.collections.ArrayList
$list.AddRange($out_find_class)
$dataGridView.DataSource = $list

$out_find_class | fl > $path
$temp = Get-Content $path
$out_txt = $temp -replace "\s{2,100}"," "
Remove-Item -Recurse $path
$outputBox_Tab_Text.Text = $out_txt | out-string
})
#endregion

#region view namespace
$button_view_namespace = New-Object System.Windows.Forms.Button
$button_view_namespace.Text = "View Namespace"
$button_view_namespace.Location = New-Object System.Drawing.Point(690,49)
$button_view_namespace.Size = New-Object System.Drawing.Size(150,28)
$GroupBox_key.Controls.Add($button_view_namespace)

$button_view_namespace.Add_Click({
$dataGridView.AutoSizeColumnsMode = "Fill"
main-var
$out_namespace = @(gwmi -ComputerName $comp -Namespace $ns -class "__NAMESPACE" | select name,__namespace,path)
$count = $out_namespace.count
$status.text = "Namespace count: $count"
$list = New-Object System.collections.ArrayList
$list.AddRange($out_namespace)
$dataGridView.DataSource = $list

$out_namespace | fl > $path
$temp = Get-Content $path
$out_txt = $temp -replace "\s{2,100}"," "
Remove-Item -Recurse $path
$outputBox_Tab_Text.Text = $out_txt | out-string
})
#endregion

#region filter class
$TextBox_Search.Add_TextChanged({
$search_text = $TextBox_Search.Text
$search_service = @($out_find_class | Where {$_.Name -match "$search_text"})
$temp = $search_service
$list = New-Object System.collections.ArrayList
$list.AddRange($temp)
$dataGridView.DataSource = $list

$count = $search_service.count
$status.text = "Class count: $count"
})
#endregion

#region open class
$button_find_object = New-Object System.Windows.Forms.Button
$button_find_object.Text = "Open Class"
$button_find_object.Location = New-Object System.Drawing.Point(10,580)
$button_find_object.Size = New-Object System.Drawing.Size(130,27)
$TabPage_table.Controls.Add($button_find_object)

$button_find_object.Add_Click({
$dataGridView.AutoSizeColumnsMode = "None"
main-var
$global:class_selected = $dataGridView.SelectedCells.Value
$status.text = "Class select: $class_selected"
$out = @(gwmi -ComputerName $comp -Namespace $ns -Class $class_selected | select *)
$list = New-Object System.collections.ArrayList
$list.AddRange($out)
$dataGridView.DataSource = $list

$out | fl > $path
$temp = Get-Content $path
$global:open_out_txt = $temp -replace "\s{2,100}"," "
Remove-Item -Recurse $path
$outputBox_Tab_Text.Text = $open_out_txt | out-string
})
#endregion

#region open methods
$button_open_methods = New-Object System.Windows.Forms.Button
$button_open_methods.Text = "Open Methods"
$button_open_methods.Location = New-Object System.Drawing.Point(150,580)
$button_open_methods.Size = New-Object System.Drawing.Size(130,27)
$TabPage_table.Controls.Add($button_open_methods)

$button_open_methods.Add_Click({
$methods_selected = @($dataGridView.SelectedCells.Value)
$outputBox_Tab_Text.Text = $methods_selected | out-string
$count = $methods_selected.count
$status.text = "Methods count: $count"
$TabControl.SelectedTab = $TabPage_text
})
#endregion

#region filter text
$TextBox_Filter = New-Object System.Windows.Forms.TextBox
$TextBox_Filter.Location = New-Object System.Drawing.Point(10,580)
$TextBox_Filter.Size = New-Object System.Drawing.Size(1335,26)
$TextBox_Filter.MultiLine = $True
$TabPage_text.Controls.Add($TextBox_Filter)

$TextBox_Filter.Add_TextChanged({
$find_item = $TextBox_Filter.Text
$find_txt = $open_out_txt -match $find_item
$outputBox_Tab_Text.Text = $find_txt | out-string
})
#endregion

<# run method
main-var
[string]$method = $textbox_method.Text
$run = (gwmi -ComputerName $comp -Namespace $ns -Class $class_selected).$method
$outputBox_Tab_Text.Text = $run | out-string
#>

#region menu
$Menu = New-Object System.Windows.Forms.MenuStrip
$Menu.BackColor = "white"
$main_form.MainMenuStrip = $Menu
$main_form.Controls.Add($Menu)

$menuItem_file = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file.Text = "File"
$Menu.Items.Add($menuItem_file)

$menuItem_file_exit = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_exit.Text = "Save text"
$menuItem_file_exit.Add_Click({
SaveFile
$outputBox_Tab_Text.Text > $path_out
})
$menuItem_file.DropDownItems.Add($menuItem_file_exit)

$menuItem_file_exit = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_exit.Text = "Exit"
$menuItem_file_exit.Add_Click({$main_form.Close()})
$menuItem_file.DropDownItems.Add($menuItem_file_exit)
#endregion

#region status
$StatusStrip = New-Object System.Windows.Forms.StatusStrip
$StatusStrip.BackColor = "white"
$StatusStrip.Font = "$Font,9"
$main_form.Controls.Add($statusStrip)

$Status = New-Object System.Windows.Forms.ToolStripMenuItem
$StatusStrip.Items.Add($Status)
$Status.Text = "©Telegram @kup57"

$main_form.Controls.Add($GroupBox_key)
$main_form.Controls.add($TabControl)
$main_form.ShowDialog()
#endregion
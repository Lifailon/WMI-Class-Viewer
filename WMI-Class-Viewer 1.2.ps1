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
$button_find_object.Size = New-Object System.Drawing.Size(120,27)
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
$button_open_methods.Location = New-Object System.Drawing.Point(140,580)
$button_open_methods.Size = New-Object System.Drawing.Size(120,27)
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

<# Run Method
main-var
[string]$method = $textbox_method.Text
$run = (gwmi -ComputerName $comp -Namespace $ns -Class $class_selected).$method
$outputBox_Tab_Text.Text = $run | out-string
#>

#region binary data
$Formatter_binaryFomatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
$System_IO_MemoryStream = New-Object System.IO.MemoryStream (,[byte[]][System.Convert]::FromBase64String('
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
4P8B2nibrmILiXkAAAAASUVORK5CYIIL'))
#endregion

#region menu
$Menu = New-Object System.Windows.Forms.MenuStrip
$Menu.BackColor = "white"
$main_form.MainMenuStrip = $Menu
$main_form.Controls.Add($Menu)

$menuItem_file = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file.Text = "File"
$menuItem_file.Image = $Formatter_binaryFomatter.Deserialize($System_IO_MemoryStream)
$Menu.Items.Add($menuItem_file)

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
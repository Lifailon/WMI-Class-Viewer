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
$main_form.Size = New-Object System.Drawing.Size(1300,850)
$main_form.AutoSize = $true

$GroupBox_key = New-Object System.Windows.Forms.GroupBox
$GroupBox_key.AutoSize = $true
$GroupBox_key.Location = New-Object System.Drawing.Point(10,10)
$GroupBox_key.Size = New-Object System.Drawing.Size(1260,1)

$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Location = New-Object System.Drawing.Point(10,120)
$TabControl.Size = New-Object System.Drawing.Size(1265,650)

$TabPage_table = New-Object System.Windows.Forms.TabPage
$TabPage_table.Text = "Table"
$TabControl.Controls.Add($TabPage_table)

$TabPage_text = New-Object System.Windows.Forms.TabPage
$TabPage_text.Text = "Text"
$TabControl.Controls.Add($TabPage_text)

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(0,2)
$dataGridView.Size = New-Object System.Drawing.Size(1255,567)
$dataGridView.Font = "$Font,10"
$dataGridView.AutoSize = $false
$dataGridView.MultiSelect = $false
$dataGridView.ReadOnly = $true
$TabPage_table.Controls.Add($dataGridView)

$outputBox_Tab_Text = New-Object System.Windows.Forms.TextBox
$outputBox_Tab_Text.Location = New-Object System.Drawing.Point(0,2)
$outputBox_Tab_Text.Size = New-Object System.Drawing.Size(1255,567)
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
$ComboBox_namespace.DataSource = @("root","root\CIMV2","root\CIMV2\Terminalservices")
$ComboBox_namespace.Location  = New-Object System.Drawing.Point(270,50)
$ComboBox_namespace.Size = New-Object System.Drawing.Size(250,30)
$GroupBox_key.Controls.Add($ComboBox_namespace)

$Label_class = New-Object System.Windows.Forms.Label
$Label_class.Text = "Class:"
$Label_class.Location = New-Object System.Drawing.Point(528,25)
$Label_class.AutoSize = $true
$GroupBox_key.Controls.Add($Label_class)

$ComboBox_class = New-Object System.Windows.Forms.ComboBox
$ComboBox_class.DataSource = @("Namespace","System","Service","Process","Product","Fix","Device","Board","Disk","Memory","Video","Network","Driver","BIOS","Startup","Share",`
"Time","User","Account","Event","Terminal")
$ComboBox_class.Location  = New-Object System.Drawing.Point(530,50)
$ComboBox_class.Size = New-Object System.Drawing.Size(250,30)
$GroupBox_key.Controls.Add($ComboBox_class)
#endregion

#region button
$button_find_class = New-Object System.Windows.Forms.Button
$button_find_class.Text = "Find Class"
$button_find_class.Location = New-Object System.Drawing.Point(790,49)
$button_find_class.Size = New-Object System.Drawing.Size(120,28)
$GroupBox_key.Controls.Add($button_find_class)

$button_find_class.Add_Click({
$dataGridView.AutoSizeColumnsMode = "Fill"
$comp = $outputBox_comp.Text
$ns = $ComboBox_namespace.Text
$class = $ComboBox_class.Text
$out = @(gwmi -ComputerName $comp -Namespace $ns -List | Where-Object {$_.name -match "$class"} | `
select name,@{Label="Properties"; Expression={$_.properties.name}},@{Label="Methods"; Expression={$_.methods.name}} | sort -Descending Methods)
$count = $out.count
$status.text = "Class count: $count"
$list = New-Object System.collections.ArrayList
$list.AddRange($out)
$dataGridView.DataSource = $list

$out | fl > $path
$temp = Get-Content $path
$out_txt = $temp -replace "\s{2,100}"," "
Remove-Item -Recurse $path
$outputBox_Tab_Text.Text = $out_txt | out-string
})

$button_find_object = New-Object System.Windows.Forms.Button
$button_find_object.Text = "Open Class"
$button_find_object.Location = New-Object System.Drawing.Point(10,580)
$button_find_object.Size = New-Object System.Drawing.Size(120,27)
$TabPage_table.Controls.Add($button_find_object)

$button_find_object.Add_Click({
$dataGridView.AutoSizeColumnsMode = "None"
$comp = $outputBox_comp.Text
$ns = $ComboBox_namespace.Text
$class_selected = $dataGridView.SelectedCells.Value
$status.text = "Class select: $class_selected"
$out = @(gwmi -ComputerName $comp -Namespace $ns -Class $class_selected | select *)
$list = New-Object System.collections.ArrayList
$list.AddRange($out)
$dataGridView.DataSource = $list

$out | fl > $path
$temp = Get-Content $path
$out_txt = $temp -replace "\s{2,100}"," "
Remove-Item -Recurse $path
$outputBox_Tab_Text.Text = $out_txt | out-string
})

$outputBox_obj = New-Object System.Windows.Forms.TextBox
$outputBox_obj.Location = New-Object System.Drawing.Point(10,580)
$outputBox_obj.Size = New-Object System.Drawing.Size(250,26)
$outputBox_obj.MultiLine = $True
$TabPage_text.Controls.Add($outputBox_obj)

$button_find_object_tab_text = New-Object System.Windows.Forms.Button
$button_find_object_tab_text.Text = "Open Class"
$button_find_object_tab_text.Location = New-Object System.Drawing.Point(270,578)
$button_find_object_tab_text.Size = New-Object System.Drawing.Size(120,29)
$TabPage_text.Controls.Add($button_find_object_tab_text)

$button_find_object_tab_text.Add_Click({
$dataGridView.AutoSizeColumnsMode = "None"
$comp = $outputBox_comp.Text
$ns = $ComboBox_namespace.Text
$class_selected = $outputBox_obj.Text
$status.text = "Class: $class_selected"
$out = gwmi -ComputerName $comp -Namespace $ns -Class $class_selected | select *
$list = New-Object System.collections.ArrayList
$list.AddRange($out)
$dataGridView.DataSource = $list

$out | fl > $path
$temp = Get-Content $path
$out_txt = $temp -replace "\s{2,100}"," "
Remove-Item -Recurse $path
$outputBox_Tab_Text.Text = $out_txt | out-string
})
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
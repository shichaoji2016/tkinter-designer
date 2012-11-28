VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsBaseControl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit

'ʵ�����пؼ���Ĺ��ô��룬��ΪVB��֧�������ļ̳У����������ؼ��ཫ��Ƕ����࣬�����Ǽ̳�

Private m_dic As Dictionary                                                     '��ǰҪ���ɴ��������/ֵ��
Private m_Type As String                                                        'ֱ�Ӷ�Ӧ��PYTHON�Ŀؼ�����
Private m_Name As String                                                        '�ؼ���
Private m_Parent As String
Private m_Value As String                                                       ' �ؼ�ֵ�������Ļ���
Private m_StyleName As String                                                   '��ʽ����
Private m_ScaleMode As Long

'���PYTHON����,
'sCmdFunc: ����������¼������ص�����;
'rel:�Ƿ�ʹ���������,
'oop:�Ƿ�ʹ�����������
'usettk:�Ƿ�ʹ��TTK������չ
Public Function toString(ByRef sCmdFunc As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean) As String
    
    If oop Then
        toString = toStringOOP(sCmdFunc, rel, IIf(Len(m_StyleName), usettk, False))
    Else
        toString = toStringStructure(sCmdFunc, rel, IIf(Len(m_StyleName), usettk, False))
    End If
    
End Function

'����ṹ������
Public Function toStringStructure(ByRef sCmdFunc As cStrBuilder, rel As Boolean, usettk As Boolean, Optional sOtherParams As String = "") As String
    
    Dim sOut As New cStrBuilder, s() As String, i As Long, extra As String, sStyle As String
    Dim sTmp As String, dTmp As Double, sCmdName As String
    
    'Debug.Assert m_Type <> "" And m_Name <> ""
    
    '�����Ҫ�����󶨣����ȴ�����Ӧ�ı���
    If Len(Dic("textvariable")) Then
        sOut.Append Space(4) & Dic("textvariable") & " = StringVar(value=" & U(Dic("text")) & ")"
    End If
    If Len(Dic("variable")) Then
        sOut.Append Space(4) & Dic("variable") & " = StringVar(value=" & U(m_Value) & ")"
    End If
    If Len(Dic("listvariable")) Then
        sOut.Append Space(4) & Dic("listvariable") & " = StringVar(value=" & U(m_Value) & ")"
    End If
    If Not usettk And Len(Dic("font")) Then
        If Left$(Dic("font"), 1) = "(" Then
            sOut.Append Space(4) & m_Name & "Font = Font(font=" & Dic("font") & ")"
        Else '����û����˼����ţ��������
            sOut.Append Space(4) & m_Name & "Font = Font(font=(" & Dic("font") & "))"
        End If
    End If
    
    If Len(Dic("columns")) Then
        sOut.Append Space(4) & Dic("columns") & " = []  " & L("l_cmtTodoCols", "#TODO���������ӱ����б�����һ�й̶�Ϊ������ʾ")
    End If
    If Len(Dic("displaycolumns")) And InStr(1, Dic("displaycolumns"), "#all") <= 0 Then
        sOut.Append Space(4) & Dic("displaycolumns") & "[]    " & L("l_cmtTodoDisCols", "#TODO������������ʾ�����б�����һ�й̶�Ϊ������ʾ")
    End If
    
    '��Ͽ�displayrowsת��Ϊheight����
    If Len(Dic("displayrows")) Then
        sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "height=" & Dic("displayrows")
    End If
    
    If usettk Then                                                              '����STYLE����
        sStyle = GetStyleParams(False, usettk)
        If Len(sStyle) Then
            sOut.Append Space(4) & "style.configure('" & m_Name & "." & m_StyleName & "'," & sStyle & ")"
            sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "style='" & m_Name & "." & m_StyleName & "'"
        End If
    End If
    
    extra = GetExtraParams(False, usettk)
    extra = extra & IIf(Len(extra) > 0 And Len(sOtherParams) > 0, ", ", "") & sOtherParams
    sOut.Append Space(4) & m_Name & " = " & m_Type & "(" & m_Parent & IIf(Len(extra), ", ", "") & extra & ")"
    sOut.Append Space(4) & m_Name & ".place(" & GetPositionParams(rel) & ")"
    sOut.Append Space(4) & "gComps['" & m_Name & "'] = " & m_Name
    
    '�����Ҫ�����󶨣�Ϊ�˷�����main()������ʹ�ã�ͬʱ���������÷���ȫ�ֿؼ��ֵ�
    If Len(Dic("textvariable")) Then
        sOut.Append Space(4) & "gComps['" & Dic("textvariable") & "'] = " & Dic("textvariable")
    End If
    If Len(Dic("variable")) Then
        sOut.Append Space(4) & "gComps['" & Dic("variable") & "'] = " & Dic("variable")
    End If
    If Len(Dic("listvariable")) Then
        sOut.Append Space(4) & "gComps['" & Dic("listvariable") & "'] = " & Dic("listvariable")
    End If
    
    '�����¼�����������ܣ�����У����¼������е��˵���ǵ���ϵͳ�ĺ���������Ҫ���ɺ�����
    If InStr(1, Dic("command"), ".") <= 0 And InStr(1, Dic("command"), "lambda ") <= 0 Then
        sCmdFunc.Append CreateFuncDef(Dic("command"), "event=None")
    End If
    If Len(Dic("postcommand")) Then
        sCmdFunc.Append CreateFuncDef(Dic("postcommand"), "event=None")
    End If
    
    '�����»��߿�ݷ�ʽ
    If Len(Dic("underline")) > 0 And Dic("underline") <> "-1" And Len(Dic("command")) > 0 Then
        sTmp = Dic("text")
        If Len(sTmp) = 0 Then sTmp = Dic("label")
        If Len(sTmp) And Len(Dic("underline")) < Len(sTmp) Then
            sOut.Append Space(4) & WTOP & ".bind_all('<Alt-" & Mid(sTmp, CLng(Dic("underline")) + 1, 1) & ">', " & Dic("command") & ")"
            If Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "a" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "z" Then
                sOut.Append Space(4) & WTOP & ".bind_all('<Alt-" & UCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', " & Dic("command") & ")"
            ElseIf Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "A" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "Z" Then
                sOut.Append Space(4) & WTOP & ".bind_all('<Alt-" & LCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', " & Dic("command") & ")"
            End If
        End If
    End If
    
    If Len(Dic("bindcommand")) Then                                             '����Ҫʹ��bind���󶨵������¼�����
        sTmp = Dic("bindcommand")
        sTmp = Replace(sTmp, "'", "")                                           '�Զ�ȥ�����źͿո�����еĻ�
        sTmp = Replace(sTmp, Chr(34), "")
        sTmp = Replace(sTmp, " ", "")
        
        s = Split(sTmp, ",")
        For i = 0 To UBound(s)
            s(i) = Trim(s(i))
            If Left(s(i), 1) = "<" And Right(s(i), 1) = ">" Then
                
                sCmdName = m_Name & "_" & Replace(Replace(Replace(s(i), "<", ""), ">", ""), "-", "_")
                
                sOut.Append Space(4) & m_Name & ".bind('" & s(i) & "', " & sCmdName & ")"
                
                sCmdFunc.Append CreateFuncDef(sCmdName, "event")
                
                'Python�Ǵ�Сд���еģ���Ӧ��ݼ�Ҳһ����������õĿ�ݼ�������ĸ�����򽫶�Ӧ�Ĵ�д/СдҲһ���
                If Right(s(i), 3) >= "-a>" And Right(s(i), 3) <= "-z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & UCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '��Ӧ��ĸ���д
                    sOut.Append Space(4) & m_Name & ".bind('" & s(i) & "', " & sCmdName & ")"
                    
                ElseIf Right(s(i), 3) >= "-A>" And Right(s(i), 3) <= "-Z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & LCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '��Ӧ��ĸ��Сд
                    sOut.Append Space(4) & m_Name & ".bind('" & s(i) & "', " & sCmdName & ")"
                    
                End If
            End If
        Next
    End If
    
    toStringStructure = sOut.toString(vbCrLf)
    
End Function

'�������������
Public Function toStringOOP(ByRef sCmdFunc As cStrBuilder, rel As Boolean, usettk As Boolean, Optional sOtherParams As String = "") As String
    
    Dim sOut As New cStrBuilder, s() As String, i As Long, extra As String
    Dim sTmp As String, sStyle As String, sCmdName As String
    
    'Debug.Assert m_Type <> "" And m_Name <> ""
    
    '�����Ҫ�����󶨣����ȴ�����Ӧ�ı���
    If Len(Dic("textvariable")) Then
        sOut.Append Space(8) & "self." & Dic("textvariable") & " = StringVar(value=" & U(Dic("text")) & ")"
    End If
    If Len(Dic("variable")) Then
        sOut.Append Space(8) & "self." & Dic("variable") & " = StringVar(value=" & U(m_Value) & ")"
    End If
    If Len(Dic("listvariable")) Then
        sOut.Append Space(8) & "self." & Dic("listvariable") & " = StringVar(value=" & U(m_Value) & ")"
    End If
    If Not usettk And Len(Dic("font")) Then
        If Left$(Dic("font"), 1) = "(" Then
            sOut.Append Space(8) & "self." & m_Name & "Font = Font(font=" & Dic("font") & ")"
        Else
            sOut.Append Space(8) & "self." & m_Name & "Font = Font(font=(" & Dic("font") & "))"
        End If
    End If
    
    If Len(Dic("columns")) Then
        sOut.Append Space(8) & "self." & Dic("columns") & " = []    " & L("l_cmtTodoCols", "#TODO���������ӱ����б�����һ�й̶�Ϊ������ʾ")
    End If
    If Len(Dic("displaycolumns")) And InStr(1, Dic("displaycolumns"), "#all") <= 0 Then
        sOut.Append Space(8) & "self." & Dic("displaycolumns") & " = []    " & L("l_cmtTodoDisCols", "#TODO������������ʾ�����б�����һ�й̶�Ϊ������ʾ")
    End If
    
    '��Ͽ�displayrowsת��Ϊheight����
    If Len(Dic("displayrows")) Then
        sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "height=" & Dic("displayrows")
    End If
    
    If usettk Then                                                              '����STYLE����
        sStyle = GetStyleParams(True, usettk)
        If Len(sStyle) Then
            sOut.Append Space(8) & "self.style.configure('" & m_Name & "." & m_StyleName & "'," & sStyle & ")"
            sOtherParams = sOtherParams & IIf(Len(sOtherParams), ", ", "") & "style='" & m_Name & "." & m_StyleName & "'"
        End If
    End If
    
    extra = GetExtraParams(True, usettk)
    extra = extra & IIf(Len(extra) > 0 And Len(sOtherParams) > 0, ", ", "") & sOtherParams
    sOut.Append Space(8) & "self." & m_Name & " = " & m_Type & "(self." & m_Parent & IIf(Len(extra), ", ", "") & extra & ")"
    sOut.Append Space(8) & "self." & m_Name & ".place(" & GetPositionParams(rel) & ")"
    
    '�����¼�����������ܣ�����У����¼������е��˵���ǵ���ϵͳ�ĺ���������Ҫ���ɺ�����
    If InStr(1, Dic("command"), ".") <= 0 And InStr(1, Dic("command"), "lambda ") <= 0 Then
        sCmdFunc.Append CreateFuncDefOOP(Dic("command"), "event=None")
    End If
    If Len(Dic("postcommand")) Then
        sCmdFunc.Append CreateFuncDefOOP(Dic("postcommand"), "event=None")
    End If
    
    '�����»��߿�ݷ�ʽ
    If Len(Dic("underline")) > 0 And Dic("underline") <> "-1" And Len(Dic("command")) > 0 Then
        sTmp = Dic("text")
        If Len(sTmp) = 0 Then sTmp = Dic("label")
        If Len(sTmp) And Len(Dic("underline")) < Len(sTmp) Then
            sOut.Append Space(8) & "self." & WTOP & ".bind_all('<Alt-" & Mid(sTmp, CLng(Dic("underline")) + 1, 1) & ">', self." & Dic("command") & ")"
            If Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "a" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "z" Then
                sOut.Append Space(8) & "self." & WTOP & ".bind_all('<Alt-" & UCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', self." & Dic("command") & ")"
            ElseIf Mid(sTmp, CLng(Dic("underline")) + 1, 1) >= "A" And Mid(sTmp, CLng(Dic("underline")) + 1, 1) <= "Z" Then
                sOut.Append Space(8) & "self." & WTOP & ".bind_all('<Alt-" & LCase(Mid(sTmp, CLng(Dic("underline")) + 1, 1)) & ">', self." & Dic("command") & ")"
            End If
        End If
    End If
    
    If Len(Dic("bindcommand")) Then                                             '����Ҫʹ��bind���󶨵������¼�����
        sTmp = Dic("bindcommand")
        sTmp = Replace(sTmp, "'", "")                                           '�Զ�ȥ�����źͿո�����еĻ�
        sTmp = Replace(sTmp, Chr(34), "")
        sTmp = Replace(sTmp, " ", "")
        
        s = Split(sTmp, ",")
        For i = 0 To UBound(s)
            s(i) = Trim(s(i))
            If Left(s(i), 1) = "<" And Right(s(i), 1) = ">" Then
                
                sCmdName = m_Name & "_" & Replace(Replace(Replace(s(i), "<", ""), ">", ""), "-", "_")
                
                sOut.Append Space(8) & "self." & m_Name & ".bind('" & s(i) & "', self." & sCmdName & ")"
                sCmdFunc.Append CreateFuncDefOOP(sCmdName, "event")
                
                'Python�Ǵ�Сд���еģ���Ӧ��ݼ�Ҳһ����������õĿ�ݼ�������ĸ�����򽫶�Ӧ�Ĵ�д/СдҲһ���
                If Right(s(i), 3) >= "-a>" And Right(s(i), 3) <= "-z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & UCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '���д
                    sOut.Append Space(8) & "self." & m_Name & ".bind('" & s(i) & "', self." & sCmdName & ")"
                    
                ElseIf Right(s(i), 3) >= "-A>" And Right(s(i), 3) <= "-Z>" Then
                    
                    s(i) = Left(s(i), Len(s(i)) - 2) & LCase(Mid(s(i), Len(s(i)) - 1, 1)) & ">" '��Сд
                    sOut.Append Space(8) & "self." & m_Name & ".bind('" & s(i) & "', self." & sCmdName & ")"
                    
                End If
            End If
        Next
    End If
    
    toStringOOP = sOut.toString(vbCrLf)
    
End Function

'����rel(�Ƿ�����������)�����ɶ�Ӧ�Ŀؼ�λ����Ϣ
Public Function GetPositionParams(rel As Boolean) As String
    If rel Then
        GetPositionParams = "relx=" & Dic("relx") & ", rely=" & Dic("rely") & ", relwidth=" & Dic("relwidth") & ", relheight=" & Dic("relheight")
    Else
        GetPositionParams = "x=" & Dic("x") & ", y=" & Dic("y") & ", width=" & Dic("width") & ", height=" & Dic("height")
    End If
End Function

'���˱�ѡ�����⣬������������û�ѡ������������б�
Public Function GetExtraParams(oop As Boolean, usettk As Boolean) As String
    
    Dim cfg As Variant, k As Variant, ks As Variant, sValue As String, s As New cStrBuilder
    
    Set ks = m_dic.Keys
    
    For Each k In ks
        If isExtra(k, usettk) And Len(Dic(k)) Then
            '��Ҫʹ�����������������ԣ�����û����ˣ����������Զ�����
            If k = "text" Or k = "label" Then
                sValue = U(Dic(k))
            ElseIf InStr(1, " fg, bg, anchor, justify, show, state, activestyle, labelanchor, mode, ", " " & k & ",") Then
                sValue = Quote(Dic(k))
            Else
                sValue = Dic(k)
            End If
            s.Append k & "=" & sValue
        End If
    Next
    
    If Len(Dic("columns")) Then s.Append "columns=" & IIf(oop, "self.", "") & Dic("columns")
    If Len(Dic("displaycolumns")) Then
        If InStr(1, Dic("displaycolumns"), "#all") <= 0 Then
            s.Append "displaycolumns=" & IIf(oop, "self.", "") & Dic("displaycolumns")
        Else
            s.Append "displaycolumns='#all'"
        End If
    End If
    
    If Len(Dic("textvariable")) Then s.Append "textvariable=" & IIf(oop, "self.", "") & Dic("textvariable")
    If Len(Dic("variable")) Then s.Append "variable=" & IIf(oop, "self.", "") & Dic("variable")
    If Len(Dic("listvariable")) Then s.Append "listvariable=" & IIf(oop, "self.", "") & Dic("listvariable")
    If Len(Dic("values")) Then s.Append "values=" & IIf(oop, "self.", "") & Dic("values")
    
    If Len(Dic("command")) Then
        If InStr(1, Dic("command"), "lambda ") > 0 Then '�������������ü�self.
            s.Append "command=" & Dic("command")
        Else
            s.Append "command=" & IIf(oop, "self.", "") & Dic("command")
        End If
    End If
    
    If Len(Dic("postcommand")) Then s.Append "postcommand=" & IIf(oop, "self.", "") & Dic("postcommand")
    If Len(Dic("xscrollcommand")) Then s.Append "xscrollcommand=" & IIf(oop, "self.", "") & Dic("xscrollcommand")
    If Len(Dic("yscrollcommand")) Then s.Append "yscrollcommand=" & IIf(oop, "self.", "") & Dic("yscrollcommand")
    If Len(Dic("font")) Then
        If usettk Then 'Entry��fontҪд�ڴ��������вŹ���
            If m_Type = "Entry" Or m_Type = "Combobox" Then s.Append "font=" & IIf(Left$(Dic("font"), 1) = "(", Dic("font"), "(" & Dic("font") & ")")
        Else
            s.Append "font=" & IIf(oop, "self.", "") & m_Name & "Font"
        End If
    End If
    
    GetExtraParams = s.toString(", ")
    
End Function

'�ж�һ�������Ƿ��Ƕ�������������TTK���жϸ��������
Private Function isExtra(ByVal sK As String, usettk As Boolean) As Boolean
    Const EXTRA_STRING As String = " x, y, relx, rely, width, height, relwidth, relheight, command, bindcommand, xscrollcommand, " & _
    " yscrollcommand, postcommand, font, textvariable, variable, listvariable, values, displayrows, columns, displaycolumns, "
    Const EXTRA_STRING_TTK As String = EXTRA_STRING & " fg, bg, bd, relief, activerelief, anchor, jump, indicatoron, resolution, "
    
    If usettk Then
        isExtra = (InStr(1, EXTRA_STRING_TTK, Space(1) & sK & ",") <= 0)
    Else
        isExtra = (InStr(1, EXTRA_STRING, Space(1) & sK & ",") <= 0)
    End If
End Function

'���ʹ����TTK��չ��ʹ�����������ȡTTK��ز����������Ϸ����ַ������б�
Private Function GetStyleParams(oop As Boolean, usettk As Boolean) As String
    Dim s As New cStrBuilder
    
    If Len(Dic("relief")) Then s.Append "relief=" & Dic("relief")
    If Len(Dic("activerelief")) Then s.Append "activerelief=" & Dic("activerelief")
    If Len(Dic("anchor")) Then s.Append "anchor=" & Quote(Dic("anchor"))
    If Len(Dic("fg")) Then s.Append "foreground=" & Quote(Dic("fg"))
    If Len(Dic("bg")) Then s.Append "background=" & Quote(Dic("bg"))
    If Len(Dic("bd")) Then s.Append "borderwidth=" & Dic("bd")
    If Len(Dic("jump")) Then s.Append "jump=" & Dic("jump")
    If Len(Dic("indicatoron")) Then s.Append "indicatoron=" & Dic("indicatoron")
    If Len(Dic("font")) Then
        If Not usettk Or (m_Type <> "Entry" And m_Type <> "Combobox") Then  'ttk.Entry��fontҪд�ڹ��������вŹ���
            If Left$(Dic("font"), 1) = "(" Then
                s.Append "font=" & Dic("font")
            Else  '����û����˼����ţ��������
                s.Append "font=(" & Dic("font") & ")"
            End If
        End If
    End If
    If Len(Dic("showvalue")) Then s.Append "showvalue=" & Dic("showvalue")
    If Len(Dic("tickinterval")) Then s.Append "tickinterval=" & Dic("tickinterval")
    If Len(Dic("sliderrelief")) Then s.Append "sliderrelief=" & Dic("sliderrelief")
    If Len(Dic("sliderlength")) Then s.Append "sliderlength=" & Dic("sliderlength")
    If Len(Dic("digits")) Then s.Append "digits=" & Dic("digits")
    
    GetStyleParams = s.toString(", ")
    
End Function

'����/��ȡ�ֵ��ֵ
Public Property Get Dic(ByVal sKey As String) As String
Attribute Dic.VB_UserMemId = 0
    If m_dic.Exists(sKey) Then Dic = m_dic(sKey)
End Property

Public Property Let Dic(ByVal sKey As String, ByVal sValue As String)
    m_dic(sKey) = sValue
End Property

Public Sub Remove(ByVal sKey As String)
    m_dic.Remove (sKey)
End Sub

'���û�ѡ������ø��µ������У�����Ϊʹ��"|"�ָ�ĺܶ������/ֵ��
Public Sub SetConfig(sAttrs As String)
    Dim sa() As String, i As Long
    
    sa = Split(sAttrs, "|")
    Debug.Assert (UBound(sa) Mod 1 = 0)
    
    m_dic.RemoveAll
    
    For i = 0 To UBound(sa) - 1 Step 2
        m_dic(sa(i)) = sa(i + 1)
    Next
    
End Sub


'�޸Ļ����ӵ������������/ֵ��"|"�ָ�
Public Sub SetSingleConfig(sAttr As String)
    Dim sa() As String
    sa = Split(sAttr, "|")
    Debug.Assert (UBound(sa) = 1)
    m_dic(sa(0)) = sa(1)
End Sub

'��������ֵ�Ŀ���ֵ�б�
'����ֵ��0-û�п�ѡֵ��1-��һ���ϸ����ƵĿ�ѡֵ�б���2-���ṩ�Ŀ�ѡֵ�б��⣬�������ֶ���������ֵ
'�����sa()��ѡֵ�б�����
Public Function GetAttrValueList(sAttr As String, ByRef sa() As String) As Long
    GetAttrValueList = 1
    Select Case sAttr
        Case "anchor"
            sa = Split("'w','n','s','e','nw','ne','sw','se','center'", ",")
        Case "relief", "overrelief"
            sa = Split("FLAT,GROOVE,RAISED,RIDGE,SOLID,SUNKEN", ",")
        Case "takefocus"
            sa = Split("1,0", ",")
        Case "state"
            sa = Split("'normal','disabled'", ",")
        Case "justify"
            sa = Split("'left','right','center'", ",")
        Case "orient"
            sa = Split("'horizontal','vertical'", ",")
        Case Else
            GetAttrValueList = 0
    End Select
            
End Function

'�����������߰���
Public Function Tips(sAttr As String) As String
    
    Tips = sAttr & vbCrLf
    Select Case sAttr:
    Case "text", "label":
        Tips = Tips & L("l_TipText", "�ؼ�����ʾ�ı���")
    Case "x", "y":
        Tips = Tips & L("l_TipXY", "�ؼ��ķ���λ�á�")
    Case "width":
        Tips = Tips & L("l_TipWidth", "�ؼ��Ŀ��ȡ�")
    Case "height":
        Tips = Tips & L("l_TipHeight", "�ؼ��ĸ߶ȡ�")
    Case "relx", "rely":
        Tips = Tips & L("l_TipRelXY", "�ؼ�����ڸ����ڵ�λ�ã�ֵ��ΧΪ0-1��")
    Case "relwidth":
        Tips = Tips & L("l_TipRelWidth", "�ؼ�����ڸ����ڵĿ��ȣ�ֵ��ΧΪ0-1��")
    Case "relheight":
        Tips = Tips & L("l_TipRelHeight", "�ؼ�����ڸ����ڵĸ߶ȣ�ֵ��ΧΪ0-1��")
    Case "fg":
        Tips = Tips & L("l_TipFg", "ǰ��ɫ����ʹ�õ����Ż�˫��������������ʽΪ#RGB��red�ȵ��ʣ�����'#FFEA00'��")
    Case "bg":
        Tips = Tips & L("l_TipBg", "����ɫ����ʹ�õ����Ż�˫��������������ʽΪ#RGB��red�ȵ��ʣ�����'#FFEA00'��")
    Case "bd":
        Tips = Tips & L("l_TipBd", "�߿���ȣ���λΪ���ء�")
    Case "anchor":
        Tips = Tips & L("l_TipAnchor", "�ؼ������ֵĶ��뷽ʽ����ʹ�õ����Ż�˫����������������ֵΪ��\n'w'|'n'|'s'|'e'|'nw'|'ne'|'sw'|'se'|'center'.")
    Case "relief":
        Tips = Tips & L("l_TipRelief", "���Ч������ѡֵ�У�FLAT, GROOVE, RAISED, RIDGE, SOLID, SUNKEN��")
    Case "overrelief":
        Tips = Tips & L("l_TipOverRelief", "�����ͣ�ڿؼ��ϵ����Ч������ѡֵ�У�FLAT, GROOVE, RAISED, RIDGE, SOLID, SUNKEN��")
    Case "takefocus":
        Tips = Tips & L("l_TipTakeFocus", "�Ƿ�����TABѡ��ؼ�������Ϊ1Ϊ����������Ϊ0��TAB�����˿ؼ���")
    Case "state":
        Tips = Tips & L("l_TipState", "�ؼ�״̬����ѡֵ�У�'normal', 'disabled'")
    Case "underline":
        Tips = Tips & L("l_TipUnderline", "���ĸ���ĸ�������»��ߣ���Ϊ��ݷ�ʽ�ı�ʾ����һ����ĸ����Ϊ0��")
    Case "justify":
        Tips = Tips & L("l_TipJustify", "���ƶ����ַ��Ķ��뷽ʽ����ʹ�õ����Ż�˫����������������ֵΪ��" & vbCrLf & "left, right, center��")
    Case "padding":
        Tips = Tips & L("l_TipPadding", "�ؼ��ڲ������࣬һ�㲻��Ҫ���á������Ҫ���ã����ṩ'�� �� �� ��'�ĸ�ֵ��������ֵ'�� �� ��'(��=��)������ֵ'�� ��'(��=��,��=��)��һ��ֵ'��'(��=��=��=��)��")
    Case "orient":
        Tips = Tips & L("l_TipOrient", "�ؼ��������ͣ�ȫ��д�������ţ�Сд����Ҫ��������������ѡֵ�У�'horizontal', 'vertical'��")
    Case "variable":
        Tips = Tips & L("l_TipVariable", "�ؼ�ֵ��һ�������󶨣�ͨ���������Ի�ȡ�����ÿؼ���ֵ��\n�����Ҫ������ԣ������������Ϊ��������")
    Case "textvariable":
        Tips = Tips & L("l_TipTextVariable", "����ʾ�ı���һ�������󶨣������仯ʱ�ؼ�����ʾ�ı����ı䣬������Ȼ��\n�����Ҫ������ԣ������������Ϊ��������")
    Case "command":
        Tips = Tips & L("l_TipCommand", "�����¼�������������������������Ҳ��������Ϊtop.destroy��tk������ʹ��lambda������")
    Case "bindcommand":
        Tips = Tips & L("l_TipBindCommand", "ʹ��bind()�󶨵��¼������б����󶨶����ʹ�ö��ŷָ�(���磺<Control-C>,<F8>,<Alt-A>)��\n˫���ı���鿴���顣")
    Case "font":
        Tips = Tips & L("l_TipFont", "�����������ԡ���һ��Ԫ�顣\nԪ��ǰ����Ԫ��Ϊ��������,�����С,֮��ļ���Ԫ�ؿ�ѡ��'bold', 'italic', 'nunderline', 'overstrike'")
    Case "xscrollcommand":
        Tips = Tips & L("l_TipXScrlCmd", "ˮƽ�����¼������������Ҫˮƽ�������������ֵΪˮƽ��������set������")
    Case "yscrollcommand":
        Tips = Tips & L("l_TipYScrlCmd", "���¹����¼������������Ҫ���¹������������ֵΪ��ֱ��������set������")
    Case "xscrollincrement":
        Tips = Tips & L("l_TipXScrlIncre", "ˮƽÿ�ι���������Ĭ��Ϊ0�����������������������Ϊһ���������������")
    Case "yscrollincrement":
        Tips = Tips & L("l_TipYScrlIncre", "����ÿ�ι���������Ĭ��Ϊ0�����������������������Ϊһ���������������")
    Case Else:
        Tips = Tips & L("l_TipUnknown", "δ֪����")
    End Select
    
End Function

Public Property Let ctlType(s As String)
    m_Type = s
End Property

'���ÿؼ��ĸ����ڣ�Ĭ����top
Public Property Let Parent(s As String)
    m_Parent = s
End Property

'���ؿؼ��ĸ����ڣ�Ĭ����top
Public Property Get Parent() As String
    Parent = m_Parent
End Property

'��ʵ���������Ŀؼ��������
Public Property Get Name() As String
    Name = m_Name
End Property
Public Property Let Name(s As String)
    m_Name = s
End Property

Public Property Let Value(s As String)
    m_Value = s
End Property

Public Property Let StyleName(s As String)
    m_StyleName = s
End Property

'�������л�����
Public Function Serializer(vSer As clsSerialization)
    vSer.Serializer m_dic
End Function

Public Function Deserializer(vSer As clsSerialization)
    vSer.Deserializer m_dic
End Function

Public Function Keys() As Collection
    Set Keys = New Collection
    Dim k As Variant
    For Each k In m_dic.Keys
        Keys.Add k
    Next
End Function

Private Sub Class_Initialize()
    m_Type = ""
    m_Name = ""
    m_Value = ""
    m_StyleName = ""
    m_Parent = WTOP
    m_ScaleMode = vbTwips
    Set m_dic = New Dictionary
End Sub

'����һ�������չǼ�; FuncName: ��������Params: ������sbody: ������
Public Function CreateFuncDef(FuncName As String, Optional sparams As String = "", Optional sbody As String = "") As String
    If Len(FuncName) = 0 Then Exit Function
    CreateFuncDef = "def " & FuncName & "(" & sparams & "):" & vbCrLf
    If Len(sbody) Then
        CreateFuncDef = CreateFuncDef & sbody & vbCrLf
    Else
        CreateFuncDef = CreateFuncDef & Space(4) & "#TODO, Please finish the function here!" & vbCrLf
        CreateFuncDef = CreateFuncDef & Space(4) & "pass" & vbCrLf
    End If
End Function

'����һ�������չǼܣ����������룩; FuncName: ��������Params: ������sbody: ������
Public Function CreateFuncDefOOP(FuncName As String, Optional sparams As String = "", Optional sbody As String = "") As String
    If Len(FuncName) = 0 Then Exit Function
    CreateFuncDefOOP = "    def " & FuncName & "(self" & IIf(Len(sparams), ", ", "") & sparams & "):" & vbCrLf
    If Len(sbody) Then
        CreateFuncDefOOP = CreateFuncDefOOP & sbody & vbCrLf
    Else
        CreateFuncDefOOP = CreateFuncDefOOP & Space(8) & "#TODO, Please finish the function here!" & vbCrLf
        CreateFuncDefOOP = CreateFuncDefOOP & Space(8) & "pass" & vbCrLf
    End If
End Function


'�����ֵ�λת��Ϊ����
Public Function toPixelX(nX As Long) As Long
    If m_ScaleMode = vbTwips Then
        toPixelX = Twip2PixelX(nX)
    ElseIf m_ScaleMode = vbPoints Then
        toPixelX = Point2PixelX(nX)
    Else
        toPixelX = nX
    End If
End Function

Public Function toPixelY(nY As Long) As Long
    If m_ScaleMode = vbTwips Then
        toPixelY = Twip2PixelY(nY)
    ElseIf m_ScaleMode = vbPoints Then
        toPixelY = Point2PixelY(nY)
    Else
        toPixelY = nY
    End If
End Function

Public Property Let ScaleMode(nV As Long)
    m_ScaleMode = nV
End Property
Public Property Get ScaleMode() As Long
    ScaleMode = m_ScaleMode
End Property



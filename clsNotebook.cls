VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsNotebook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'ѡ��࣬�������úͱ�����Ӧ�����Ժ�ֵ�������ɶ�ӦPYTHON��TKinter����

Private m_dicTotal As Dictionary       '����ȫ�������ԣ�����Ĭ��ֵ
Private m_Base As clsBaseControl       '�����ؼ���
Private m_TabTitles() As String        'ѡ����⣬��1��ʼ��0��ʵ��û��
Private m_Tabs() As Object             'ѡ������±��1��ʼ�ģ�0ʵ��û��
Private m_nTabs As Long                'ѡ���Ŀ
Private m_CanbeOutByMainForm As Boolean

'���PYTHON����,
'sCmdFunc: ����������¼������ص�����;
'rel:�Ƿ�ʹ���������,
'oop:�Ƿ�ʹ�����������
'usettk:�Ƿ�ʹ��TTK������չ
Public Function toString(ByRef sCmdFunc As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean) As String
    
    toString = m_Base.toString(sCmdFunc, rel, oop, usettk) & vbCrLf & CreateTabWidgets(sCmdFunc, rel, oop, usettk)
    
End Function

Private Function CreateTabWidgets(ByRef sCmdFunc As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean) As String
    
    Dim sOut As New cStrBuilder, i As Long, nTabs As Long, s As String
    Dim bTabExisted As Boolean, sCaption As String
    
    nTabs = IIf(m_nTabs > UBound(m_Tabs), m_nTabs, UBound(m_Tabs))
    
    For i = 1 To nTabs  'TAB�±��1��ʼ
        If i > UBound(m_Tabs) Then
            bTabExisted = False
        ElseIf m_Tabs(i) Is Nothing Then
            bTabExisted = False
        Else
            bTabExisted = True
        End If
        
        '����ʹ��TabStrip���õ�ѡ��ҳ���⣬���Ϊ�գ���ʹ��Frame�ؼ��ı��⡣
        If bTabExisted Then
            If i > m_nTabs Then
                sCaption = m_Tabs(i).Caption
            ElseIf Len(m_TabTitles(i)) = 0 Then
                sCaption = m_Tabs(i).Caption
            ElseIf i <= m_nTabs Then
                sCaption = m_TabTitles(i)
            End If
        ElseIf i <= m_nTabs Then
            sCaption = m_TabTitles(i)
        End If
        If Len(sCaption) = 0 Then sCaption = "Tab" & i
        
        sOut.Append CreateSingleTabWidget(sCmdFunc, rel, oop, usettk, i, bTabExisted, sCaption)
    Next
    
    CreateTabWidgets = sOut.toString(vbCrLf)
    
End Function

Private Function CreateSingleTabWidget(ByRef sCmdFunc As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean, _
                                        nTabIdx As Long, bUseTabObj As Boolean, sCaption As String) As String
    Dim s As String, sOut As New cStrBuilder
    
    If oop Then
        If bUseTabObj Then
            s = "self." & m_Tabs(nTabIdx).Name
            sOut.Append vbCrLf & Space(8) & s & " = Frame(self." & m_Base.Name & ")"
            sOut.Append m_Tabs(nTabIdx).toString(sCmdFunc, rel, oop, usettk)
        Else
            s = "self." & m_Base.Name & "__Tab" & nTabIdx
            sOut.Append vbCrLf & Space(8) & s & " = Frame(self." & m_Base.Name & ")"
            sOut.Append Space(8) & s & "Lbl = Label(" & s & ", text='Please add widgets in code.')"
            sOut.Append Space(8) & s & "Lbl.place(relx=0.1,rely=0.5)"
        End If
        
        sOut.Append Space(8) & "self." & m_Base.Name & ".add(" & s & ", text=" & U(sCaption) & ")"
    Else
        If bUseTabObj Then
            s = m_Tabs(nTabIdx).Name
            sOut.Append vbCrLf & Space(4) & s & " = Frame(" & m_Base.Name & ")"
            sOut.Append m_Tabs(nTabIdx).toString(sCmdFunc, rel, oop, usettk)
        Else
            s = m_Base.Name & "__Tab" & nTabIdx
            sOut.Append vbCrLf & Space(4) & s & " = Frame(" & m_Base.Name & ")"
            sOut.Append Space(4) & s & "Lbl = Label(" & s & ", text='Please add widgets in code.')"
            sOut.Append Space(4) & s & "Lbl.place(relx=0.1,rely=0.5)"
        End If
        
        sOut.Append Space(4) & m_Base.Name & ".add(" & s & ", text=" & U(sCaption) & ")"
    End If
    
    CreateSingleTabWidget = sOut.toString(vbCrLf)
    
End Function


'���������Ҫ���ϵ������������ʼ��������
Public Sub InitConfig(o As Object, parentWidth As Long, parentHeight As Long)
    
    Dim i As Long, oiTabs As ITabs
    
    m_Base.Name = o.Properties("Name")
    
    Set oiTabs = o.Properties("Tabs").object
    m_nTabs = oiTabs.Count
    
    ReDim m_TabTitles(m_nTabs) As String
    For i = 1 To m_nTabs
        m_TabTitles(i) = oiTabs.Item(i).Caption  'TAB�±��1��ʼ
    Next
    
    '��Щ�����е�Ĭ��ֵ
    m_dicTotal("x") = m_Base.toPixelX(o.Properties("Left"))
    m_dicTotal("y") = m_Base.toPixelY(o.Properties("Top"))
    m_dicTotal("width") = m_Base.toPixelX(o.Properties("Width"))
    m_dicTotal("height") = m_Base.toPixelY(o.Properties("Height"))
    m_dicTotal("relx") = Format(o.Properties("Left") / parentWidth, "0.###")
    m_dicTotal("rely") = Format(o.Properties("Top") / parentHeight, "0.###")
    m_dicTotal("relwidth") = Format(o.Properties("Width") / parentWidth, "0.###")
    m_dicTotal("relheight") = Format(o.Properties("Height") / parentHeight, "0.###")
    m_dicTotal("relief") = "FLAT"
    m_dicTotal("takefocus") = IIf(o.Properties("TabStop"), 1, 0)
    m_dicTotal("bindcommand") = ""
    
    '��Щ��Ĭ��ѡ���
    m_Base("x") = m_dicTotal("x")
    m_Base("y") = m_dicTotal("y")
    m_Base("width") = m_dicTotal("width")
    m_Base("height") = m_dicTotal("height")
    m_Base("relx") = m_dicTotal("relx")
    m_Base("rely") = m_dicTotal("rely")
    m_Base("relwidth") = m_dicTotal("relwidth")
    m_Base("relheight") = m_dicTotal("relheight")
    If m_dicTotal("takefocus") = 0 Then m_Base("takefocus") = m_dicTotal("takefocus")
    
End Sub

'����һ����ǩҳ
Public Sub AddTab(oTab As Object, nTabIdx As Long)
    
    If nTabIdx > UBound(m_Tabs) Then
        ReDim Preserve m_Tabs(nTabIdx) As Object
    End If
    
    Set m_Tabs(nTabIdx) = oTab
    
End Sub

'��������ֵ�Ŀ���ֵ�б�
'����ֵ��0-û�п�ѡֵ��1-��һ���ϸ����ƵĿ�ѡֵ�б���2-���ṩ�Ŀ�ѡֵ�б��⣬�������ֶ���������ֵ
'�����sa()��ѡֵ�б�����
Public Function GetAttrValueList(sAttr As String, ByRef sa() As String) As Long
    GetAttrValueList = m_Base.GetAttrValueList(sAttr, sa)
End Function

Public Function Tips(sAttr As String) As String
    Tips = m_Base.Tips(sAttr)
End Function

'���û�ѡ������ø��µ������У�����Ϊʹ��"|"�ָ�ĺܶ������/ֵ��
Public Sub SetConfig(sAttrs As String)
    m_Base.SetConfig sAttrs
End Sub

'�޸Ļ����ӵ������������/ֵ��"|"�ָ�
Public Sub SetSingleConfig(sAttr As String)
    m_Base.SetSingleConfig sAttr
End Sub

'����һ�����ϣ�ÿ����Ŀ��Ԫ��"������|ֵ|�Ƿ�Ĭ��ѡ��"
'�����������������������Բ����б���
Public Function Allitems() As Collection
    Dim re As Collection, k As Variant, ks As Collection
    
    Set re = New Collection
    
    '��׼����
    Set ks = m_dicTotal.Keys
    For Each k In ks
        If Len(m_Base(k)) Then
            re.Add k & "|" & m_Base(k) & "|1"
        Else
            re.Add k & "|" & m_dicTotal(k) & "|0"
        End If
    Next
    
    '�û����ӵ��Զ������������еĻ���
    Set ks = m_Base.Keys
    For Each k In ks
        If Not m_dicTotal.Exists(k) Then
            re.Add k & "|" & m_Base(k) & "|1"
        End If
    Next
    
    Set Allitems = re
    
End Function

Private Sub Class_Initialize()
    Set m_dicTotal = New Dictionary
    Set m_Base = New clsBaseControl
    m_Base.ctlType = "Notebook"
    m_Base.StyleName = "TNotebook"
    ReDim m_TabTitles(0) As String
    ReDim m_Tabs(0) As Object
    m_CanbeOutByMainForm = True
End Sub

Private Sub Class_Terminate()
    Set m_dicTotal = Nothing
    Set m_Base = Nothing
    Erase m_Tabs
    Erase m_TabTitles
End Sub

Public Property Let Parent(s As String)
    m_Base.Parent = s
End Property

Public Property Get Parent() As String
    Parent = m_Base.Parent
End Property

Public Property Get Name() As String
    Name = m_Base.Name
End Property

'���ڸı���Ĭ�϶�Ӧ��widget���ͣ��޸�widget���ͺ�ע�������б��ĺϷ���
Public Function SetWidgetType(sType As String, sStyleName As String)
    m_Base.ctlType = sType
    m_Base.StyleName = sStyleName
End Function

'ȷ�������������ܷ������toString()���������룬Ĭ��ΪTrue������ΪFalse˵�����������������ô���
Public Property Get EnableOutByMainForm() As Boolean
    EnableOutByMainForm = m_CanbeOutByMainForm
End Property
Public Property Let EnableOutByMainForm(bEnable As Boolean)
    m_CanbeOutByMainForm = bEnable
End Property

'�������л�����
Public Function Serializer(vSer As clsSerialization)
    vSer.Serializer m_Base
End Function

Public Function Deserializer(vSer As clsSerialization)
    vSer.Deserializer m_Base
End Function

Public Property Get Description() As String
    Description = L("l_DescNotebook", "ѡ����󣬶�Ӧ��Tkinter.ttk��Notebook�ؼ���")
End Property

Public Property Let ScaleMode(nV As Long)
    m_Base.ScaleMode = nV
End Property

'����ģ��Ƚ�����ĺ�����ʵ�������ж����������������ϵ
'�ñ��������һ������Ƚϣ��߼����Ϊ'������-��һ������'
'����ֵ���壺
'<0����ʾ��������Ҫ����һ������ǰ�������
'=0����ʾ���߽�û��������ϵ������ǰ��˳����Ӱ��
'>0����һ������Ҫ��������롣
'������߼�����������صĳ���
Public Function Compare(ByRef Obj As Object) As Long
    If Parent = Obj.Name Then '���ؼ����������
        Compare = 1
    ElseIf Obj.Parent = Name Then
        Compare = -1
    ElseIf Parent = WTOP And Obj.Parent <> WTOP Then '����ؼ������
        Compare = -1
    ElseIf Parent <> WTOP And Obj.Parent = WTOP Then
        Compare = 1
    Else
        Compare = 0
    End If
End Function



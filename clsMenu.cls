VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMenu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'�˵��࣬�����������Ŀؼ�����һЩ��ͬ����ΪҪ�����˵�Ƕ�׵��������

Private m_dicTotal As Dictionary                                                '����ȫ�������ԣ�����Ĭ��ֵ
Private m_Base As clsBaseControl                                                '�����ؼ���

Private m_Childs() As Object
Private m_numChilds As Long
Private m_IdxCurChild As Long
Private m_CanbeOutByMainForm As Boolean

'���PYTHON����,
'sCmdFunc: ����������¼������ص�����;
'rel:�Ƿ�ʹ���������,
'oop:�Ƿ�ʹ�����������
'usettk:�Ƿ�ʹ��TTK������չ
Public Function toString(ByRef sCmd As cStrBuilder, rel As Boolean, oop As Boolean, usettk As Boolean) As String
    
    If oop Then
        toString = toStringOOP(sCmd, rel)
    Else
        toString = toStringStructure(sCmd, rel)
    End If
    
End Function

'����ṹ������
Private Function toStringStructure(ByRef sCmd As cStrBuilder, rel As Boolean) As String
    
    Dim sOut As New cStrBuilder, s() As String, i As Long, extra As String
    
    extra = IIf(Len(m_Base("tearoff")), ", tearoff=" & m_Base("tearoff"), "")
    
    sOut.Append Space(4) & m_Base.Name & " = Menu(" & m_Base.Parent & extra & ")"
    
    '�������������˵����������˵��µ��Ӳ˵��ɸ������˵��������ɶ�Ӧ�Ĵ���
    For i = 0 To m_numChilds - 1
        sOut.Append m_Childs(i).toString(sCmd, rel, False, False)
    Next
    
    sOut.Append Space(4) & m_Base.Parent & "['menu'] = " & m_Base.Name
    sOut.Append Space(4) & "gComps['" & m_Base.Name & "'] = " & m_Base.Name
    
    toStringStructure = sOut.toString(vbCrLf)
    
End Function

'�������������
Private Function toStringOOP(ByRef sCmd As cStrBuilder, rel As Boolean) As String
    
    Dim sOut As New cStrBuilder, s() As String, i As Long, extra As String
    
    extra = IIf(Len(m_Base("tearoff")), ", tearoff=" & m_Base("tearoff"), "")
    
    sOut.Append Space(8) & "self." & m_Base.Name & " = Menu(self." & m_Base.Parent & extra & ")"
    
    '�������������˵����������˵��µ��Ӳ˵��ɸ������˵��������ɶ�Ӧ�Ĵ���
    For i = 0 To m_numChilds - 1
        sOut.Append m_Childs(i).toString(sCmd, rel, True, False)
    Next
    
    sOut.Append Space(8) & "self." & m_Base.Parent & "['menu'] = self." & m_Base.Name
    
    toStringOOP = sOut.toString(vbCrLf)
    
End Function

'���������Ҫ���ϵ������������ʼ��������
Public Sub InitConfig(Optional o As Object, Optional parentWidth As Long, Optional parentHeight As Long)
    
    m_Base("tearoff") = "0"
    
    '��Щ�����е�Ĭ��ֵ
    m_dicTotal("tearoff") = "0"
    m_dicTotal("label") = ""
    m_dicTotal("fg") = ""
    m_dicTotal("bg") = ""
    m_dicTotal("bd") = ""
    m_dicTotal("relief") = ""
    m_dicTotal("state") = ""
    m_dicTotal("underline") = "-1"
    m_dicTotal("variable") = m_Base.Name & "Var"
    m_dicTotal("font") = ""
    
End Sub

'��������ֵ�Ŀ���ֵ�б�
'����ֵ��0-û�п�ѡֵ��1-��һ���ϸ����ƵĿ�ѡֵ�б���2-���ṩ�Ŀ�ѡֵ�б��⣬�������ֶ���������ֵ
'�����sa()��ѡֵ�б�����
Public Function GetAttrValueList(sAttr As String, ByRef sa() As String) As Long
    If sAttr = "tearoff" Then
        GetAttrValueList = 1
        sa = Split("1,0", ",")
    Else
        GetAttrValueList = m_Base.GetAttrValueList(sAttr, sa)
    End If
End Function

Public Function Tips(sAttr As String) As String
    
    If sAttr = "tearoff" Then
        Tips = sAttr & vbCrLf & L("l_TipTearOff", "�˵��Ƿ���Ա�ɵ������ڣ�����Ϊ1��Ĭ�ϣ�ʱ���˵���һ��Ϊ���ߣ��û�����������߻Ὣ�˵�����Ϊһ�������Ĵ��ڣ�����PYTHONĬ�ϱ༭��IDLEһ����")
    ElseIf sAttr = "postcommand" Then
        Tips = sAttr & vbCrLf & L("l_TipPostCmdMenu", "ÿ���û�����˵�����ʱ���õĻص�������")
    Else
        Tips = m_Base.Tips(sAttr)
    End If
    
End Function

Private Sub Class_Initialize()
    Set m_dicTotal = New Dictionary
    Set m_Base = New clsBaseControl
    m_Base.Name = "MainMenu"
    m_Base.ctlType = "Menu"
    m_Base.StyleName = ""
    Erase m_Childs
    m_numChilds = 0
    m_IdxCurChild = 0
    m_CanbeOutByMainForm = True
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

Public Sub SetConfig(sAttrs As String)
    m_Base.SetConfig sAttrs
End Sub

Public Sub SetSingleConfig(sAttr As String)
    m_Base.SetSingleConfig sAttr
End Sub

Private Sub Class_Terminate()
    Set m_dicTotal = Nothing
    Set m_Base = Nothing
    Erase m_Childs
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

Public Property Let Name(s As String)
    m_Base.Name = s
End Property

'���ڸı���Ĭ�϶�Ӧ��widget���ͣ��޸�widget���ͺ�ע�������б��ĺϷ���
Public Function SetWidgetType(sType As String, sStyleName As String)
    'm_Base.ctlType = sType
    'm_Base.StyleName = sStyleName
End Function

'ȷ�������������ܷ������toString()���������룬Ĭ��ΪTrue������ΪFalse˵�����������������ô���
Public Property Get EnableOutByMainForm() As Boolean
    EnableOutByMainForm = m_CanbeOutByMainForm
End Property
Public Property Let EnableOutByMainForm(bEnable As Boolean)
    m_CanbeOutByMainForm = bEnable
End Property

'�������л�����
Public Sub Serializer(vSer As clsSerialization)
    vSer.Serializer m_Base
End Sub

Public Sub Deserializer(vSer As clsSerialization)
    vSer.Deserializer m_Base
End Sub

Public Property Get Description() As String
    Description = L("l_DescMenu", "���˵����󣬶�Ӧ��Tkinter��Menu�ؼ���")
End Property

Public Sub AddChild(o As Object)
    ReDim Preserve m_Childs(m_numChilds) As Object
    Set m_Childs(m_numChilds) = o
    m_numChilds = m_numChilds + 1
End Sub

Public Function GetNextChild(Optional nIdxChild As Long = -1) As Object
    
    m_IdxCurChild = IIf(nIdxChild >= 0, nIdxChild, m_IdxCurChild)
    If m_IdxCurChild < m_numChilds Then
        Set GetNextChild = m_Childs(m_IdxCurChild)
        m_IdxCurChild = m_IdxCurChild + 1
    Else
        Set GetNextChild = Nothing
        m_IdxCurChild = 0
    End If
End Function

Public Property Get ChildCount() As Long
    ChildCount = m_numChilds
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


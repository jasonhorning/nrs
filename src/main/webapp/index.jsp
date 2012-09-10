<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>NENA Registry System</title>
    <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/resources/nrs.css" media="screen"/>
</head>
<body>

<h1>NENA Registry System - Preview - README</h1>
<p>
    This is a preview of the NRS application. What's being demonstrated by this preview is the basic structure of the
    registry editing screen. This screen is the most complex part of the application, and by focusing on this area I was
    able to flesh out the most time consuming parts of the underlying application framework.
</p>

<h3>Links</h3>
<ul>
    <li>Admin: <a href="admin/elementState">elementState</a></li>
    <li>Admin: <a href="admin/">new registry with default fields</a></li>
    <li>Admin: <a href="admin/_references">NRS Reference Documents</a></li>
</ul>

<h3>A note about table grids</h3>
<p>
    I had significant trouble finding a suitable library for the "grid" user interface element. This is the part of the
    software that provides the table structure which allows the user to edit the data directly in the table. The grid
    library I selected provides a compromise between user functionality and programmer simplicity. I wanted this
    component to be relatively easy to maintain by other programmers, and other grid libraries had steeper learning
    curves. One sacrifice of this grid library is that it does not support tab-control at all, which I find a little
    inconvenient. But since only NRS administrators, not the public, will be using this control, I think it's workable.
</p>

<h3>A note about saving data</h3>
<p>
    This preview does not yet save changes to registry data. Feel free to make any changes you like. Play with the
    editing controls, and get a feel for how the user interface elements will work for you. When you reload the page,
    your changes will be gone.
</p>

<h3>Upcoming functionality - in no particular order</h3>
<ul>
    <li>Admin: View/edit a list of registries</li>
    <li>Admin: Save registry changes</li>
    <li>Admin: Require authentication to access admin screens</li>
    <li>Public: View a list of NRS registries</li>
    <li>Public: View a registry as a web page</li>
    <li>Public: Download a registry as an XML schema</li>
</ul>
</body>
</html>

<%@ page import="java.sql.*" %>

<%
    if (session.getAttribute("student") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String roll = request.getParameter("roll");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Student Attendance</title>
    <style>
        body { font-family:Arial; background:#eef2f3; padding:40px; }
        table {
            width:70%;
            margin:auto;
            background:white;
            border-collapse: collapse;
            box-shadow:0 0 10px gray;
        }
        th, td {
            padding:12px;
            border:1px solid #ccc;
            text-align:center;
        }
        th { background:#00aa55; color:white; }
    </style>
</head>
<body>

<h2 style="text-align:center;">Attendance for Roll: <%= roll %></h2>

<table>
    <tr>
        <th>Date</th>
        <th>Status</th>
    </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hostel_db", "root", "admin");

        PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM attendance WHERE roll_no=?"
        );
        ps.setString(1, roll);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
%>
    <tr>
        <td><%= rs.getString("date") %></td>
        <td><%= rs.getString("status") %></td>
    </tr>
<%
        }

        con.close();
    } catch (Exception e) {
        out.print("<tr><td colspan='2'>Error: " + e + "</td></tr>");
    }
%>

</table>

<div style="text-align:center; margin-top:30px;">
    <a href="hostel.jsp" style="background:#007bff; color:white; padding:10px 20px; border-radius:5px; text-decoration:none;">Back</a>
</div>

</body>
</html>

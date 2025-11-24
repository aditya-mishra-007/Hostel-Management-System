<%@ page import="java.sql.*" %>

<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String roll = request.getParameter("roll");
    String msg = "";

    if (request.getMethod().equals("POST")) {

        String status = request.getParameter("status");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hostel_db", "root", "admin"
            );

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO attendance(roll_no, date, status) VALUES (?, CURDATE(), ?)"
            );
            ps.setString(1, roll);
            ps.setString(2, status);
            ps.executeUpdate();

            msg = "Attendance marked successfully!";
        }
        catch(Exception e){
            msg = "Error: " + e.getMessage();
        }

    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Mark Attendance</title>
    <style>
        body { background:#eef2f3; font-family:Arial; text-align:center; padding-top:60px; }
        .box {
            width:350px; margin:auto; background:white; padding:20px;
            border-radius:10px; box-shadow:0 0 10px gray;
        }
        select, button {
            width:100%; padding:12px; margin:10px 0;
            border-radius:5px; border:1px solid #888;
        }
        button {
            background:green; color:white; border:none; cursor:pointer;
        }
    </style>
</head>
<body>

<div class="box">
    <h2>Mark Attendance</h2>
    <h3>Roll No: <%= roll %></h3>

    <form method="post">
        <select name="status" required>
            <option value="">Select Status</option>
            <option value="Present">Present</option>
            <option value="Absent">Absent</option>
        </select>

        <button type="submit">Submit</button>
    </form>

    <p style="color:green;"><%= msg %></p>

    <a href="view_students.jsp">⬅ Back</a>
</div>

</body>
</html>

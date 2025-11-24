<%@ page import="java.sql.*" %>
<%
    String msg = "";

    if (request.getMethod().equals("POST")) {
        String u = request.getParameter("roll");
        String p = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hostel_db",
                    "root",
                    "admin"
            );

            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM students WHERE roll_no=? AND password=?"
            );
            ps.setString(1, u);
            ps.setString(2, p);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("student", u);
                response.sendRedirect("hostel.jsp?user=student");
                return;
            } else {
                msg = "Invalid Login!";
            }
            con.close();

        } catch (Exception e) {
            msg = e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Student Login</title>
    <style>
        body { background:#f2f2f2; font-family:Arial; padding-top:80px; text-align:center; }
        .box {
            width:350px; margin:auto; background:white;
            padding:25px; border-radius:10px; box-shadow:0 0 10px gray;
        }
        input {
            width:100%; padding:12px; margin:8px 0; border:1px solid #bbb;
            border-radius:5px;
        }
        .btn {
            background:#00aa55; color:white; border:none;
            padding:12px; width:100%; border-radius:5px;
            cursor:pointer;
        }
    </style>
</head>
<body>

<div class="box">
    <h2>Student Login</h2>

    <form method="post">
        <input type="text" name="roll" placeholder="Enter Roll No" required>
        <input type="password" name="password" placeholder="Enter Password" required>
        <button class="btn">Login</button>
    </form>

    <p style="color:red;"><%= msg %></p>
</div>

</body>
</html>

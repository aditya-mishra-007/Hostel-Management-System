<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Student Login & Room Info</title>
    <style>
        body { font-family: Arial; }
        .box { width: 400px; margin: 50px auto; border: 1px solid #333; padding: 20px; border-radius: 10px; }
        input { width: 95%; padding: 8px; margin: 5px 0; }
        input[type=submit] { width: 100%; background-color: #4CAF50; color: white; cursor: pointer; }
        table { width: 80%; margin: 20px auto; border-collapse: collapse; }
        th, td { border: 1px solid #333; padding: 10px; text-align: center; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>

<div class="box">
<h2 style="text-align:center;">Student Login</h2>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if(email != null && password != null) {
        String url = "jdbc:mysql://localhost:3306/hostel_db";
        String dbUser = "root"; // replace with your DB username
        String dbPass = "admin";     // replace with your DB password

        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            // Check login
            String loginQuery = "SELECT * FROM students WHERE email=? AND password=?";
            pst = conn.prepareStatement(loginQuery);
            pst.setString(1, email);
            pst.setString(2, password);
            rs = pst.executeQuery();

            if(rs.next()) {
                int studentId = rs.getInt("id");
                String name = rs.getString("name");
                String roomNo = rs.getString("room_no");

%>
<h3 style="text-align:center;">Welcome, <%= name %></h3>
<p style="text-align:center;">Your Room Number: <strong><%= roomNo != null ? roomNo : "Not Assigned" %></strong></p>

<%
                if(roomNo != null) {
%>
<h3 style="text-align:center;">Your Roommates:</h3>
<table>
    <tr><th>Name</th><th>Email</th></tr>
<%
                    String roommatesQuery = "SELECT name, email FROM students WHERE room_no=? AND id<>?";
                    pst = conn.prepareStatement(roommatesQuery);
                    pst.setString(1, roomNo);
                    pst.setInt(2, studentId);
                    ResultSet roommates = pst.executeQuery();

                    boolean hasRoommates = false;
                    while(roommates.next()) {
                        hasRoommates = true;
%>
    <tr>
        <td><%= roommates.getString("name") %></td>
        <td><%= roommates.getString("email") %></td>
    </tr>
<%
                    }
                    if(!hasRoommates) {
%>
    <tr><td colspan="2">No roommates assigned.</td></tr>
<%
                    }
%>
</table>
<%
                }

            } else {
%>
<p style="color:red; text-align:center;">Invalid email or password!</p>
<%
            }

        } catch(Exception e) {
            out.println("<p style='color:red; text-align:center;'>Error: "+e.getMessage()+"</p>");
        } finally {
            try { if(rs != null) rs.close(); } catch(Exception e) {}
            try { if(pst != null) pst.close(); } catch(Exception e) {}
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    } else {
%>
<form method="post" action="login.jsp">
    <input type="email" name="email" placeholder="Email" required /><br/>
    <input type="password" name="password" placeholder="Password" required /><br/>
    <input type="submit" value="Login" />
</form>
<%
    }
%>

</div>
</body>
</html>

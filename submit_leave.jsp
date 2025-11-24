<%@ page import="java.sql.*" %>

<%
    // Only logged-in students can apply for leave
    if (session.getAttribute("student") == null) {
        response.sendRedirect("student_login.jsp");
        return;
    }

    String message = "";

    // When form submitted
    if (request.getParameter("submit") != null) {
        String roll_no = (String) session.getAttribute("student_roll");
        String name = (String) session.getAttribute("student_name");

        String reason = request.getParameter("reason");
        String from = request.getParameter("from_date");
        String to = request.getParameter("to_date");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hostel_db", "root", "admin");

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO leave_requests (roll_no, name, reason, from_date, to_date, status) VALUES (?,?,?,?,?,?)"
            );

            ps.setString(1, roll_no);
            ps.setString(2, name);
            ps.setString(3, reason);
            ps.setString(4, from);
            ps.setString(5, to);
            ps.setString(6, "Pending");

            ps.executeUpdate();
            con.close();

            message = "Leave request submitted successfully!";

        } catch (Exception e) {
            message = "Error: " + e;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Submit Leave Request</title>
    <style>
        body { font-family: Arial; background:#eef2f3; padding:40px; }
        .box {
            width: 50%;
            margin: auto;
            padding: 25px;
            background: white;
            box-shadow: 0 0 10px gray;
            border-radius: 8px;
        }
        input, textarea {
            width: 100%;
            padding: 10px;
            margin-top: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        textarea { height: 100px; }
        button {
            background:#007bff;
            color:white;
            padding:12px;
            width:100%;
            border:none;
            border-radius:5px;
            cursor:pointer;
        }
        button:hover { background:#0056b3; }
        p.msg { text-align:center; color: green; font-weight:bold; }
        a { display:block; text-align:center; margin-top:20px; }
    </style>
</head>

<body>

<h2 style="text-align:center;">Submit Leave Request</h2>

<div class="box">

    <% if (!message.equals("")) { %>
        <p class="msg"><%= message %></p>
    <% } %>

    <form method="post">

        <label>Reason for Leave:</label>
        <textarea name="reason" required></textarea>

        <label>From Date:</label>
        <input type="date" name="from_date" required>

        <label>To Date:</label>
        <input type="date" name="to_date" required>

        <button type="submit" name="submit">Submit Request</button>

    </form>

</div>

<a href="student_dashboard.jsp">⬅ Back to Dashboard</a>

</body>
</html>

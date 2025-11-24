<%@ page import="java.sql.*" %>

<%
    // AUTHENTICATION CHECK
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hostel Management | Rooms</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f4f6f9;
            color: #333;
        }

        .main-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 15px;
        }

        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            margin-bottom: 30px;
            background: #fff;
        }

        .card-header {
            background: #fff;
            border-bottom: 1px solid #eee;
            padding: 20px 25px;
            border-radius: 12px 12px 0 0 !important;
        }

        .card-header h4 {
            margin: 0;
            font-weight: 600;
            color: #2c3e50;
        }

        .form-control, .form-select {
            border-radius: 8px;
            padding: 10px 15px;
            border: 1px solid #e0e0e0;
            background-color: #f8f9fa;
        }

        .form-control:focus, .form-select:focus {
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.15);
            border-color: #0d6efd;
        }

        .btn-custom {
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-primary-custom {
            background-color: #4361ee;
            border-color: #4361ee;
            color: white;
        }

        .btn-primary-custom:hover {
            background-color: #304ffe;
            transform: translateY(-2px);
        }

        .table-custom th {
            background-color: #f8f9fa;
            color: #6c757d;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.85rem;
            border-bottom: 2px solid #eee;
        }

        .table-custom td {
            vertical-align: middle;
            padding: 15px;
            border-bottom: 1px solid #eee;
        }

        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .status-available { background-color: #d1fae5; color: #065f46; }
        .status-occupied { background-color: #fee2e2; color: #991b1b; }
        .status-maintenance { background-color: #fef3c7; color: #92400e; }

        .action-btn {
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
            margin: 0 3px;
            text-decoration: none;
            transition: all 0.2s;
        }

        .edit-btn { background-color: #e0f2fe; color: #0284c7; }
        .edit-btn:hover { background-color: #0284c7; color: white; }

        .delete-btn { background-color: #fee2e2; color: #dc2626; }
        .delete-btn:hover { background-color: #dc2626; color: white; }

        /* Highlight the edit section when active */
        .edit-mode-active {
            border: 2px solid #ffc107;
            animation: pulse 1s;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0.4); }
            70% { box-shadow: 0 0 0 10px rgba(255, 193, 7, 0); }
            100% { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0); }
        }
    </style>
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
    <div class="container">
        <!-- Dashboard Link Fix: Pointing directly to dashboard.jsp -->
        <a class="navbar-brand" href="dashboard.jsp"><i class="fas fa-hotel me-2"></i>Hostel Admin</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <!-- Dashboard Link Fix -->
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link active" href="manage_rooms.jsp">Rooms</a></li>
                <li class="nav-item"><a class="nav-link" href="logout.jsp">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="main-container">

    <!-- ADD ROOM CARD -->
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h4><i class="fas fa-plus-circle me-2 text-primary"></i>Add New Room</h4>
        </div>
        <div class="card-body">
            <form method="post" class="row g-3">
                <div class="col-md-5">
                    <label class="form-label text-muted small">Room Number</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="fas fa-door-open text-muted"></i></span>
                        <input type="text" name="room_no" class="form-control border-start-0 ps-0" placeholder="e.g. A-101" required>
                    </div>
                </div>
                <div class="col-md-5">
                    <label class="form-label text-muted small">Capacity</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="fas fa-users text-muted"></i></span>
                        <input type="number" name="capacity" class="form-control border-start-0 ps-0" placeholder="e.g. 2" required>
                    </div>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" name="add_room" class="btn btn-primary-custom btn-custom w-100">
                        <i class="fas fa-save me-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%-- JAVA LOGIC: INSERT ROOM --%>
    <%
        if (request.getParameter("add_room") != null) {
            String roomNo = request.getParameter("room_no");
            int capacity = Integer.parseInt(request.getParameter("capacity"));

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hostel_db", "root", "admin");
                PreparedStatement ps = con.prepareStatement("INSERT INTO rooms (room_no, capacity) VALUES (?, ?)");
                ps.setString(1, roomNo);
                ps.setInt(2, capacity);
                ps.executeUpdate();
                con.close();
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error: " + e + "</div>");
            }
            response.sendRedirect("manage_rooms.jsp");
        }
    %>

    <%-- JAVA LOGIC: DELETE ROOM --%>
    <%
        if (request.getParameter("delete") != null) {
            int rid = Integer.parseInt(request.getParameter("delete"));
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hostel_db", "root", "admin");
                PreparedStatement ps = con.prepareStatement("DELETE FROM rooms WHERE room_id=?");
                ps.setInt(1, rid);
                ps.executeUpdate();
                con.close();
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error: " + e + "</div>");
            }
            response.sendRedirect("manage_rooms.jsp");
        }
    %>

    <!-- ROOM LIST TABLE -->
    <div class="card">
        <div class="card-header">
            <h4><i class="fas fa-list-ul me-2 text-primary"></i>Room List</h4>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-custom table-hover mb-0">
                    <thead>
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Room No</th>
                            <th>Capacity</th>
                            <th>Occupied</th>
                            <th>Status</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hostel_db", "root", "admin");
                                PreparedStatement ps = con.prepareStatement("SELECT * FROM rooms ORDER BY room_no ASC");
                                ResultSet rs = ps.executeQuery();

                                while (rs.next()) {
                                    String status = rs.getString("status");
                                    String badgeClass = "bg-secondary";
                                    if("Available".equalsIgnoreCase(status)) badgeClass = "status-available";
                                    else if("Occupied".equalsIgnoreCase(status)) badgeClass = "status-occupied";
                                    else if("Maintenance".equalsIgnoreCase(status)) badgeClass = "status-maintenance";
                        %>
                        <tr>
                            <td class="ps-4 text-muted">#<%= rs.getInt("room_id") %></td>
                            <td class="fw-bold"><%= rs.getString("room_no") %></td>
                            <td><i class="fas fa-bed text-muted me-1"></i> <%= rs.getInt("capacity") %></td>
                            <td><i class="fas fa-user text-muted me-1"></i> <%= rs.getInt("occupied") %></td>
                            <td><span class="status-badge <%= badgeClass %>"><%= status %></span></td>
                            <td class="text-end pe-4">
                                <a href="manage_rooms.jsp?edit=<%= rs.getInt("room_id") %>#editSection" class="action-btn edit-btn" title="Edit">
                                    <i class="fas fa-pen"></i>
                                </a>
                                <a href="manage_rooms.jsp?delete=<%= rs.getInt("room_id") %>" class="action-btn delete-btn" title="Delete" onclick="return confirm('Are you sure you want to delete this room?');">
                                    <i class="fas fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                con.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6' class='text-center text-danger p-3'>Error: " + e + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- UPDATE LOGIC (Updated to Include Occupied Field) -->
    <%
        if (request.getParameter("update_room") != null) {
            int rid = Integer.parseInt(request.getParameter("rid"));
            String roomNo = request.getParameter("room_no");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String status = request.getParameter("status");
            int occupiedVal = Integer.parseInt(request.getParameter("occupied_flag"));

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hostel_db", "root", "admin");
                // Added occupied=? to the query
                PreparedStatement ps = con.prepareStatement("UPDATE rooms SET room_no=?, capacity=?, status=?, occupied=? WHERE room_id=?");
                ps.setString(1, roomNo);
                ps.setInt(2, capacity);
                ps.setString(3, status);
                ps.setInt(4, occupiedVal); // Saving the occupied value
                ps.setInt(5, rid);
                ps.executeUpdate();
                con.close();
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error: " + e + "</div>");
            }
            response.sendRedirect("manage_rooms.jsp");
        }
    %>

    <!-- EDIT FORM (CONDITIONAL RENDER) -->
    <%
        if (request.getParameter("edit") != null) {
            int rid = Integer.parseInt(request.getParameter("edit"));
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hostel_db", "root", "admin");
                PreparedStatement ps = con.prepareStatement("SELECT * FROM rooms WHERE room_id=?");
                ps.setInt(1, rid);
                ResultSet rs = ps.executeQuery();
                if(rs.next()) {
                    int occupiedCount = rs.getInt("occupied");
                    String isOccupied = occupiedCount > 0 ? "1" : "0"; // Logic to determine initial yes/no
    %>

    <div id="editSection" class="card edit-mode-active mt-4">
        <div class="card-header bg-warning-subtle text-warning-emphasis">
            <h4><i class="fas fa-edit me-2"></i>Edit Room Details</h4>
        </div>
        <div class="card-body">
            <form method="post" class="row g-3">
                <input type="hidden" name="rid" value="<%= rid %>">

                <div class="col-md-3">
                    <label class="form-label fw-bold">Room No</label>
                    <input type="text" name="room_no" class="form-control" value="<%= rs.getString("room_no") %>" required>
                </div>

                <div class="col-md-3">
                    <label class="form-label fw-bold">Capacity</label>
                    <input type="number" name="capacity" class="form-control" value="<%= rs.getInt("capacity") %>" required>
                </div>

                <div class="col-md-3">
                    <label class="form-label fw-bold">Status</label>
                    <!-- Added ID for JS logic -->
                    <select name="status" id="statusSelect" class="form-select" onchange="autoToggleOccupied()">
                        <option <%= rs.getString("status").equals("Available") ? "selected" : "" %>>Available</option>
                        <option <%= rs.getString("status").equals("Occupied") ? "selected" : "" %>>Occupied</option>
                        <option <%= rs.getString("status").equals("Maintenance") ? "selected" : "" %>>Maintenance</option>
                    </select>
                </div>

                <!-- Added Option for Occupied Yes/No -->
                <div class="col-md-3">
                    <label class="form-label fw-bold">Is Occupied?</label>
                    <select name="occupied_flag" id="occupiedSelect" class="form-select">
                        <option value="0" <%= isOccupied.equals("0") ? "selected" : "" %>>No</option>
                        <option value="1" <%= isOccupied.equals("1") ? "selected" : "" %>>Yes</option>
                    </select>
                </div>

                <div class="col-12 text-end mt-4">
                    <a href="manage_rooms.jsp" class="btn btn-light border me-2">Cancel</a>
                    <button type="submit" name="update_room" class="btn btn-warning text-dark fw-bold">
                        <i class="fas fa-check-circle me-1"></i> Update Room
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Auto scroll to edit section
        document.getElementById('editSection').scrollIntoView({ behavior: 'smooth' });

        // Logic: When Status changes, auto-set Is Occupied?
        function autoToggleOccupied() {
            var status = document.getElementById("statusSelect").value;
            var occupiedSelect = document.getElementById("occupiedSelect");

            if (status === "Occupied") {
                occupiedSelect.value = "1"; // Set to Yes
            } else if (status === "Available") {
                occupiedSelect.value = "0"; // Set to No
            }
            // Maintenance logic left flexible (user can choose)
        }
    </script>

    <%
                }
                con.close();
            } catch (Exception e) {
                 out.println("<div class='alert alert-danger'>Error retrieving room data: " + e + "</div>");
            }
        }
    %>

</div> <!-- End Main Container -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%@ page import="java.sql.*" %>

<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("student") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String roll = request.getParameter("roll");
    String pageTitle = "Attendance History";
    String DB_URL = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "admin";

    // Variables for Summary Calculation (Calculated in loop below)
    int totalDays = 0;
    int presentDays = 0;
    int absentDays = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0b0f19;
            /* Student Theme Background Gradient */
            background-image:
                radial-gradient(circle at 0% 0%, rgba(168, 85, 247, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 100% 100%, rgba(79, 70, 229, 0.15) 0%, transparent 50%);
            min-height: 100vh;
            color: #e2e8f0;
        }

        h1, h2, h3, h4 { font-family: 'Space Grotesk', sans-serif; }

        /* --- GLASS COMPONENTS --- */
        .glass-card {
            background: rgba(30, 41, 59, 0.4);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.5);
        }

        /* --- NEON STAT CARDS --- */
        .stat-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            background: rgba(255, 255, 255, 0.05);
        }

        /* --- TABLE STYLING --- */
        .table-header {
            background: rgba(15, 23, 42, 0.8);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .table-row {
            border-bottom: 1px solid rgba(255, 255, 255, 0.03);
            transition: background 0.2s;
        }
        .table-row:hover {
            background: rgba(255, 255, 255, 0.03);
        }

        /* --- BADGES --- */
        .badge-present {
            background: rgba(34, 197, 94, 0.15);
            color: #4ade80;
            border: 1px solid rgba(34, 197, 94, 0.2);
            box-shadow: 0 0 10px rgba(34, 197, 94, 0.1);
        }
        .badge-absent {
            background: rgba(239, 68, 68, 0.15);
            color: #f87171;
            border: 1px solid rgba(239, 68, 68, 0.2);
            box-shadow: 0 0 10px rgba(239, 68, 68, 0.1);
        }

    </style>
</head>
<body class="p-4 sm:p-8 flex items-center justify-center min-h-screen">

<div class="w-full max-w-4xl space-y-6 animate-fade-in-up">

    <!-- Header Section -->
    <div class="glass-card rounded-2xl p-6 relative overflow-hidden">
        <!-- Decorative Glow -->
        <div class="absolute top-0 right-0 w-64 h-64 bg-indigo-500/10 rounded-full blur-3xl pointer-events-none -mr-16 -mt-16"></div>

        <div class="relative z-10 flex flex-col md:flex-row justify-between items-center gap-4">
            <div>
                <h2 class="text-3xl font-bold text-white mb-1 tracking-tight">Attendance Record</h2>
                <div class="flex items-center gap-2 text-indigo-300 bg-indigo-500/10 px-3 py-1 rounded-full w-fit border border-indigo-500/20">
                    <i data-lucide="user" class="h-4 w-4"></i>
                    <span class="text-sm font-medium">Roll No: <%= roll %></span>
                </div>
            </div>

            <a href="hostel.jsp" class="group flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/5 border border-white/10 hover:bg-white/10 hover:border-white/20 transition-all text-sm font-medium text-slate-300 hover:text-white">
                <i data-lucide="arrow-left" class="h-4 w-4 group-hover:-translate-x-1 transition-transform"></i>
                Back to Dashboard
            </a>
        </div>
    </div>

    <!-- Main Data Container -->
    <div class="glass-card rounded-2xl overflow-hidden flex flex-col md:flex-row">

        <!-- Sidebar / Summary Stats (Simulated Data) -->
        <div class="md:w-1/3 p-6 border-b md:border-b-0 md:border-r border-white/5 bg-slate-900/30 flex flex-col justify-center gap-4">
            <h4 class="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Analytics Overview</h4>

            <!-- Present Card -->
            <div class="stat-card p-4 rounded-xl flex items-center justify-between group">
                <div>
                    <p class="text-3xl font-bold text-green-400 group-hover:scale-110 transition-transform origin-left">90%</p>
                    <p class="text-xs text-slate-400 uppercase tracking-wide mt-1">Attendance Rate</p>
                </div>
                <div class="h-10 w-10 rounded-full bg-green-500/10 flex items-center justify-center border border-green-500/20">
                    <i data-lucide="trending-up" class="h-5 w-5 text-green-400"></i>
                </div>
            </div>

            <!-- Absent Card -->
            <div class="stat-card p-4 rounded-xl flex items-center justify-between group">
                <div>
                    <p class="text-3xl font-bold text-red-400 group-hover:scale-110 transition-transform origin-left">10</p>
                    <p class="text-xs text-slate-400 uppercase tracking-wide mt-1">Days Absent</p>
                </div>
                <div class="h-10 w-10 rounded-full bg-red-500/10 flex items-center justify-center border border-red-500/20">
                    <i data-lucide="alert-circle" class="h-5 w-5 text-red-400"></i>
                </div>
            </div>

            <!-- Total Classes -->
            <div class="stat-card p-4 rounded-xl flex items-center justify-between group">
                <div>
                    <p class="text-3xl font-bold text-indigo-400 group-hover:scale-110 transition-transform origin-left">100</p>
                    <p class="text-xs text-slate-400 uppercase tracking-wide mt-1">Total Classes</p>
                </div>
                <div class="h-10 w-10 rounded-full bg-indigo-500/10 flex items-center justify-center border border-indigo-500/20">
                    <i data-lucide="calendar" class="h-5 w-5 text-indigo-400"></i>
                </div>
            </div>
        </div>

        <!-- Attendance Table -->
        <div class="md:w-2/3 overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="table-header">
                    <tr>
                        <th class="px-6 py-4 text-xs font-bold text-slate-400 uppercase tracking-wider">Date</th>
                        <th class="px-6 py-4 text-xs font-bold text-slate-400 uppercase tracking-wider text-right">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-white/5">

                <%
                    boolean foundAttendance = false;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

                        PreparedStatement ps = con.prepareStatement(
                                "SELECT attendance_date, status FROM attendance WHERE roll_no=? ORDER BY attendance_date DESC"
                        );
                        ps.setString(1, roll);

                        ResultSet rs = ps.executeQuery();

                        while (rs.next()) {
                            foundAttendance = true;
                            String date = rs.getString("attendance_date");
                            String status = rs.getString("status");

                            // Theme Logic
                            String badgeClass = "bg-slate-700/50 text-slate-300 border-slate-600"; // Default
                            String statusIcon = "minus";

                            if ("Present".equalsIgnoreCase(status)) {
                                badgeClass = "badge-present";
                                statusIcon = "check";
                            } else if ("Absent".equalsIgnoreCase(status)) {
                                badgeClass = "badge-absent";
                                statusIcon = "x";
                            }
                %>
                    <tr class="table-row group">
                        <td class="px-6 py-4 text-sm font-medium text-slate-200">
                            <div class="flex items-center gap-3">
                                <div class="h-8 w-8 rounded-lg bg-white/5 flex items-center justify-center text-slate-400 group-hover:bg-indigo-500/20 group-hover:text-indigo-400 transition-colors">
                                    <i data-lucide="calendar-days" class="h-4 w-4"></i>
                                </div>
                                <%= date != null ? new java.text.SimpleDateFormat("dd MMM, yyyy").format(rs.getDate("attendance_date")) : "N/A" %>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider <%= badgeClass %>">
                                <i data-lucide="<%= statusIcon %>" class="h-3 w-3"></i>
                                <%= status %>
                            </span>
                        </td>
                    </tr>
                <%
                        }

                        if (!foundAttendance) {
                %>
                    <tr>
                        <td colspan="2" class="px-6 py-12 text-center">
                            <div class="flex flex-col items-center justify-center text-slate-500">
                                <div class="h-16 w-16 bg-slate-800/50 rounded-full flex items-center justify-center mb-4">
                                    <i data-lucide="clipboard-x" class="h-8 w-8"></i>
                                </div>
                                <p class="text-lg font-medium text-slate-300">No Records Found</p>
                                <p class="text-sm">Attendance data is empty for this roll number.</p>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                        if (con != null) con.close();
                    } catch (Exception e) {
                %>
                    <tr>
                        <td colspan="2" class="p-6">
                            <div class="bg-red-500/10 border border-red-500/20 rounded-xl p-4 flex items-center gap-3 text-red-400">
                                <i data-lucide="alert-triangle" class="h-6 w-6 shrink-0"></i>
                                <div>
                                    <p class="font-bold">Database Error</p>
                                    <p class="text-sm opacity-80"><%= e.getMessage() %></p>
                                </div>
                            </div>
                        </td>
                    </tr>
                <%
                    }
                %>

                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>

<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // --- AUTHENTICATION & DATA RETRIEVAL ---
    if (session.getAttribute("student") == null) {
        response.sendRedirect("student_login.jsp"); // Redirect back to login
        return;
    }

    // Retrieve session data
    String rollNo = (String) session.getAttribute("student_roll");
    // Fallback if roll is just stored in 'student'
    if (rollNo == null) rollNo = (String) session.getAttribute("student");

    String studentName = (String) session.getAttribute("student_name");
    if (studentName == null) studentName = "Student";

    String currentRoomNo = (String) session.getAttribute("student_room"); // Value will be null if room_no is NULL in DB

    String pageTitle = "My Room Allocation";

    String url = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String dbUser = "root";
    String dbPass = "admin";

    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
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
                radial-gradient(circle at 80% 10%, rgba(168, 85, 247, 0.15) 0%, transparent 40%),
                radial-gradient(circle at 20% 90%, rgba(99, 102, 241, 0.15) 0%, transparent 40%);
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
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        /* --- GLOW TEXT --- */
        .text-glow {
            text-shadow: 0 0 20px rgba(168, 85, 247, 0.5);
        }
        .text-glow-green {
            text-shadow: 0 0 20px rgba(74, 222, 128, 0.5);
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
            background: rgba(255, 255, 255, 0.05);
        }

        /* --- ANIMATIONS --- */
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-5px); }
        }
        .animate-float { animation: float 4s ease-in-out infinite; }

    </style>
</head>

<body class="flex flex-col items-center justify-center min-h-screen p-4 sm:p-6">

<div class="w-full max-w-4xl animate-fade-in-up">

    <!-- Header -->
    <div class="text-center mb-10">
        <div class="inline-flex items-center justify-center h-16 w-16 rounded-2xl bg-gradient-to-br from-indigo-500/20 to-purple-500/20 border border-white/10 mb-4 shadow-lg shadow-indigo-500/10 animate-float">
            <i data-lucide="bed-double" class="h-8 w-8 text-indigo-400"></i>
        </div>
        <h2 class="text-4xl font-bold text-white tracking-tight mb-2">Room Allocation</h2>
        <p class="text-slate-400">Welcome, <span class="text-indigo-300 font-semibold"><%= studentName %></span></p>
    </div>

    <!-- Main Content Glass Card -->
    <div class="glass-card rounded-3xl p-8 relative overflow-hidden">

        <!-- Background Decor -->
        <div class="absolute top-0 right-0 w-96 h-96 bg-purple-500/5 rounded-full blur-3xl -mr-20 -mt-20 pointer-events-none"></div>

        <%
            // Check if room_no is available
            if (currentRoomNo == null || currentRoomNo.trim().isEmpty() || "null".equalsIgnoreCase(currentRoomNo)) {
        %>
            <%-- ROOM NOT ALLOCATED STATE --%>
            <div class="flex flex-col items-center justify-center py-12 text-center">
                <div class="h-24 w-24 bg-red-500/10 rounded-full flex items-center justify-center border border-red-500/20 mb-6 shadow-[0_0_30px_rgba(239,68,68,0.2)]">
                    <i data-lucide="home-x" class="h-10 w-10 text-red-500"></i>
                </div>
                <h3 class="text-2xl font-bold text-white mb-2">No Room Assigned</h3>
                <p class="text-slate-400 max-w-md mx-auto">
                    Your profile is active, but a room has not been allocated yet. Please contact the hostel warden.
                </p>
            </div>
        <%
            } else {
        %>
            <%-- ROOM ALLOCATED STATE --%>

            <!-- Top Grid: My Details -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
                <!-- Roll No Card -->
                <div class="p-5 rounded-2xl bg-white/5 border border-white/10 flex items-center gap-4">
                    <div class="h-12 w-12 rounded-xl bg-slate-800 flex items-center justify-center text-slate-400">
                        <i data-lucide="fingerprint" class="h-6 w-6"></i>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-slate-500 uppercase tracking-wider">My Roll No</p>
                        <p class="text-xl font-mono font-bold text-white"><%= rollNo %></p>
                    </div>
                </div>

                <!-- Room No Card (Highlighted) -->
                <div class="p-5 rounded-2xl bg-gradient-to-br from-green-500/10 to-emerald-500/10 border border-green-500/20 flex items-center justify-between relative overflow-hidden group">
                    <div class="relative z-10 flex items-center gap-4">
                        <div class="h-12 w-12 rounded-xl bg-green-500/20 flex items-center justify-center text-green-400">
                            <i data-lucide="key" class="h-6 w-6"></i>
                        </div>
                        <div>
                            <p class="text-xs font-bold text-green-400/70 uppercase tracking-wider">Assigned Room</p>
                            <p class="text-3xl font-black text-white text-glow-green"><%= currentRoomNo %></p>
                        </div>
                    </div>
                    <!-- Glow Effect -->
                    <div class="absolute right-0 top-0 h-full w-20 bg-green-500/20 blur-xl group-hover:bg-green-500/30 transition-all"></div>
                </div>
            </div>

            <!-- Roommates Section -->
            <div class="border-t border-white/10 pt-8">
                <h3 class="text-xl font-bold text-white mb-6 flex items-center gap-2">
                    <i data-lucide="users" class="h-5 w-5 text-indigo-400"></i>
                    <span>Roommates</span>
                </h3>

                <div class="overflow-hidden rounded-xl border border-white/10 bg-slate-900/20">
                    <table class="w-full text-left border-collapse">
                        <thead class="table-header">
                            <tr>
                                <th class="px-6 py-4 text-xs font-bold text-slate-400 uppercase tracking-wider">Name</th>
                                <th class="px-6 py-4 text-xs font-bold text-slate-400 uppercase tracking-wider hidden sm:table-cell">Contact</th>
                                <th class="px-6 py-4 text-xs font-bold text-slate-400 uppercase tracking-wider text-right">Roll No</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/5">
                            <%
                                boolean hasRoommates = false;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection(url, dbUser, dbPass);

                                    // Query to find other students in the same room
                                    String roommatesQuery = "SELECT name, email, roll_no FROM students WHERE room_no=? AND roll_no<>?";
                                    pst = conn.prepareStatement(roommatesQuery);
                                    pst.setString(1, currentRoomNo);
                                    pst.setString(2, rollNo); // Exclude self
                                    rs = pst.executeQuery();

                                    while(rs.next()) {
                                        hasRoommates = true;
                            %>
                            <tr class="table-row group">
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="h-8 w-8 rounded-full bg-indigo-500/20 flex items-center justify-center text-indigo-300 text-xs font-bold border border-indigo-500/30">
                                            <%= rs.getString("name").substring(0, 1) %>
                                        </div>
                                        <span class="font-medium text-slate-200 group-hover:text-white transition-colors"><%= rs.getString("name") %></span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-sm text-slate-400 hidden sm:table-cell">
                                    <%= rs.getString("email") %>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-md text-xs font-medium bg-slate-800 text-slate-300 border border-slate-700">
                                        <%= rs.getString("roll_no") %>
                                    </span>
                                </td>
                            </tr>
                            <%
                                    }
                                    if(!hasRoommates) {
                            %>
                            <tr>
                                <td colspan="3" class="px-6 py-12 text-center text-slate-500">
                                    <i data-lucide="ghost" class="h-8 w-8 mx-auto mb-2 opacity-50"></i>
                                    <p>You have no roommates yet.</p>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch(Exception e) {
                            %>
                            <tr>
                                <td colspan="3" class="px-6 py-4">
                                    <div class="bg-red-500/10 text-red-400 p-3 rounded-lg border border-red-500/20 text-sm">
                                        Error loading data: <%= e.getMessage() %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                } finally {
                                    try { if(rs != null) rs.close(); } catch(Exception e) {}
                                    try { if(pst != null) pst.close(); } catch(Exception e) {}
                                    try { if(conn != null) conn.close(); } catch(Exception e) {}
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        <%
            }
        %>
    </div>

    <!-- Navigation -->
    <div class="text-center mt-8">
        <a href="javascript:history.back()" class="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-indigo-400 transition-colors">
            <i data-lucide="layout-dashboard" class="h-4 w-4"></i>
            <span>Back to Dashboard</span>
        </a>
    </div>

</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
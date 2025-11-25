<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String pageTitle = "Leave Requests Approval";
    String message = "";
    String messageType = "success";

    // Database credentials
    String DB_URL = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "admin";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // --- HANDLE DUMMY DATA INSERTION ---
        if ("add_dummy_requests".equals(request.getParameter("action"))) {
            String[][] dummyRequests = {
                {"H101", "Priya Sharma", "Attending sister's wedding in native place.", "2025-12-01", "2025-12-07"},
                {"H105", "Rohan Verma", "Urgent medical appointment outside the city.", "2025-11-26", "2025-11-27"},
                {"H210", "Sneha Kumari", "Family function: Grandmother's birthday.", "2025-12-10", "2025-12-10"},
                {"H305", "Amit Dube", "University sports competition practice.", "2025-12-05", "2025-12-06"},
                {"H402", "Jasmine Kaur", "Required at home for cultural ceremony.", "2025-12-15", "2025-12-18"},
                {"H511", "Vikram Yadav", "Dental surgery appointment in city hospital.", "2025-11-28", "2025-11-28"},
                {"H055", "Deepa Patel", "Outstation exam for a competitive test.", "2025-12-03", "2025-12-04"},
                {"H201", "Karan Singh", "Vehicle breakdown, need to visit mechanic.", "2025-11-27", "2025-11-27"},
                {"H312", "Esha Reddy", "Visiting ailing parent in nearby town.", "2025-12-20", "2025-12-24"},
                {"H420", "Zahid Khan", "To attend younger brother's school event.", "2025-12-12", "2025-12-12"}
            };

            int insertedCount = 0;
            String insertSql = "INSERT INTO leave_requests (roll_no, name, reason, from_date, to_date, status) VALUES (?, ?, ?, ?, ?, 'Pending')";
            ps = con.prepareStatement(insertSql);

            for (String[] req : dummyRequests) {
                ps.setString(1, req[0]);
                ps.setString(2, req[1]);
                ps.setString(3, req[2]);
                ps.setString(4, req[3]);
                ps.setString(5, req[4]);
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int result : results) {
                if (result > 0) insertedCount++;
            }

            if (insertedCount > 0) {
                message = "Successfully added **" + insertedCount + "** testing leave requests.";
                messageType = "success";
            } else {
                message = "Failed to add testing leave requests. Check table structure.";
                messageType = "error";
            }
            if (ps != null) ps.close();

            response.sendRedirect(request.getRequestURI() + "?message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&type=" + messageType);
            return;
        }


        // --- HANDLE APPROVE / REJECT LOGIC ---
        String action = request.getParameter("action");
        String id = request.getParameter("id");

        if (action != null && id != null) {
            String newStatus = "";
            String updateMessage = "";

            if (action.equals("approve")) {
                newStatus = "Approved";
                updateMessage = "Leave request ID **" + id + "** approved.";
            } else if (action.equals("reject")) {
                newStatus = "Rejected";
                updateMessage = "Leave request ID **" + id + "** rejected.";
            }

            if (!newStatus.isEmpty()) {
                ps = con.prepareStatement("UPDATE leave_requests SET status=? WHERE id=?");
                ps.setString(1, newStatus);
                ps.setString(2, id);

                if (ps.executeUpdate() > 0) {
                    message = updateMessage;
                    messageType = "success";
                } else {
                    message = "Could not find pending request ID " + id + ".";
                    messageType = "error";
                }
                if (ps != null) ps.close();

                response.sendRedirect(request.getRequestURI() + "?message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&type=" + messageType);
                return;
            }
        }

    } catch (Exception e) {
        message = "Database Error: " + e.getMessage();
        messageType = "error";
        e.printStackTrace();
    } finally {
        // Connection remains open for fetching data below
    }
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
            background-color: #0f172a;
            /* Admin Command Center Background */
            background-image:
                linear-gradient(180deg, rgba(6, 182, 212, 0.05) 0%, rgba(15, 23, 42, 0) 30%),
                radial-gradient(circle at 100% 0%, rgba(16, 185, 129, 0.08) 0%, transparent 40%),
                radial-gradient(circle at 0% 0%, rgba(6, 182, 212, 0.08) 0%, transparent 40%);
            min-height: 100vh;
            color: #e2e8f0;
        }

        h1, h2, h3, h4 { font-family: 'Space Grotesk', sans-serif; }

        /* --- GLASS COMPONENTS --- */
        .glass-card {
            background: rgba(30, 41, 59, 0.6);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        /* --- TABLE STYLING --- */
        .table-header {
            background: rgba(15, 23, 42, 0.9);
            border-bottom: 1px solid rgba(6, 182, 212, 0.2);
        }
        .table-row {
            border-bottom: 1px solid rgba(255, 255, 255, 0.03);
            transition: all 0.2s;
        }
        .table-row:hover {
            background: rgba(6, 182, 212, 0.05);
        }

        /* --- STATUS BADGES --- */
        .status-Approved { background: rgba(16, 185, 129, 0.1); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.2); box-shadow: 0 0 10px rgba(16, 185, 129, 0.1); }
        .status-Rejected { background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); }
        .status-Pending { background: rgba(245, 158, 11, 0.1); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.2); animation: pulse 2s infinite; }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }

    </style>
</head>

<body class="p-4 sm:p-6 min-h-screen">

<div class="max-w-7xl mx-auto animate-fade-in-up">

    <!-- Header & Actions -->
    <div class="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">Leave Requests</h2>
            <div class="flex items-center gap-2 mt-1 text-slate-400">
                <i data-lucide="inbox" class="h-4 w-4"></i>
                <span class="text-sm">Manage student outpass applications</span>
            </div>
        </div>

        <div class="flex items-center gap-3">
            <a href="?action=add_dummy_requests" class="group bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white font-medium py-2.5 px-5 rounded-xl border border-slate-700 hover:border-slate-500 transition-all flex items-center gap-2 text-sm">
                <i data-lucide="database" class="h-4 w-4 text-slate-500 group-hover:text-white"></i>
                <span>Pending Requests</span>
            </a>

            <a href="hostel.jsp" class="group flex items-center gap-2 px-5 py-2.5 rounded-xl bg-cyan-900/20 border border-cyan-500/30 hover:bg-cyan-500/20 transition-all text-sm font-medium text-cyan-400 hover:text-cyan-300">
                <i data-lucide="layout-dashboard" class="h-4 w-4 group-hover:-translate-x-1 transition-transform"></i>
                Dashboard
            </a>
        </div>
    </div>

    <%-- Message Display --%>
    <% if (!message.isEmpty()) {
        String urlMessage = request.getParameter("message");
        String urlType = request.getParameter("type");
        if (urlMessage != null) {
            message = urlMessage;
            messageType = urlType;
        }
    %>
        <div class="mb-6 p-4 rounded-xl flex items-center gap-3 border backdrop-blur-md shadow-lg animate-bounce-short
            <% if ("success".equals(messageType)) { %> bg-emerald-500/10 border-emerald-500/20 text-emerald-400
            <% } else { %> bg-red-500/10 border-red-500/20 text-red-400 <% } %>">
            <i data-lucide="<%= "success".equals(messageType) ? "check-circle" : "alert-triangle" %>" class="h-5 w-5"></i>
            <p class="font-medium text-sm"><%= message %></p>
        </div>
    <% } %>

    <!-- Requests Table -->
    <div class="glass-card rounded-2xl overflow-hidden border border-slate-700/50">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="table-header">
                    <tr>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">ID</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Student</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Reason</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">From Date</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">To Date</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider text-center">Status</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-white/5">

                <%
                    boolean fetchSuccess = false;
                    try {
                        if (con == null || con.isClosed()) {
                            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                        }

                        // Select all requests
                        ps = con.prepareStatement(
                            "SELECT id, roll_no, name, reason, from_date, to_date, status FROM leave_requests ORDER BY id DESC"
                        );
                        rs = ps.executeQuery();
                        boolean foundRequests = false;

                        while (rs.next()) {
                            foundRequests = true;
                            int reqId = rs.getInt("id");
                            String rollNo = rs.getString("roll_no");
                            String name = rs.getString("name");
                            String reason = rs.getString("reason");
                            String fromDate = rs.getString("from_date");
                            String toDate = rs.getString("to_date");
                            String status = rs.getString("status");
                %>

                <tr class="table-row group">
                    <td class="px-6 py-4">
                        <span class="font-mono text-xs text-slate-500">#<%= reqId %></span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex flex-col">
                            <span class="text-sm font-bold text-white"><%= name %></span>
                            <span class="text-xs font-mono text-cyan-400 bg-cyan-500/10 px-1.5 py-0.5 rounded w-fit mt-0.5"><%= rollNo %></span>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="max-w-xs text-sm text-slate-300 truncate" title="<%= reason %>">
                            <%= reason %>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <span class="flex items-center gap-2 text-sm text-slate-300">
                            <i data-lucide="calendar-arrow-up" class="h-4 w-4 text-emerald-400"></i>
                            <%= fromDate %>
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <span class="flex items-center gap-2 text-sm text-slate-300">
                            <i data-lucide="calendar-arrow-down" class="h-4 w-4 text-amber-400"></i>
                            <%= toDate %>
                        </span>
                    </td>

                    <td class="px-6 py-4 text-center">
                        <span class="px-2.5 py-1 inline-flex text-[10px] leading-5 font-bold uppercase tracking-widest rounded-full <%= "status-" + status %>">
                            <%= status %>
                        </span>
                    </td>

                    <td class="px-6 py-4 text-right">
                        <% if ("Pending".equals(status)) { %>
                            <div class="flex items-center justify-end gap-2">
                                <a href="?action=approve&id=<%= reqId %>" title="Approve"
                                   class="p-2 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 hover:bg-emerald-500 hover:text-white transition-all shadow-lg shadow-emerald-500/10">
                                    <i data-lucide="check" class="h-4 w-4"></i>
                                </a>
                                <a href="?action=reject&id=<%= reqId %>" title="Reject"
                                   class="p-2 rounded-lg bg-red-500/10 text-red-400 border border-red-500/20 hover:bg-red-500 hover:text-white transition-all shadow-lg shadow-red-500/10">
                                    <i data-lucide="x" class="h-4 w-4"></i>
                                </a>
                            </div>
                        <% } else { %>
                            <span class="text-slate-600 text-xs italic flex items-center justify-end gap-1">
                                <i data-lucide="lock" class="h-3 w-3"></i> Locked
                            </span>
                        <% } %>
                    </td>
                </tr>

                <%
                        }

                        if (!foundRequests) {
                %>
                    <tr>
                        <td colspan="7" class="px-6 py-16 text-center text-slate-500">
                            <div class="flex flex-col items-center">
                                <i data-lucide="inbox" class="h-12 w-12 mb-4 opacity-20"></i>
                                <p class="text-lg font-medium">No requests found</p>
                                <p class="text-sm opacity-60">Click "Load Test Data" to populate.</p>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                        fetchSuccess = true;
                    } catch (Exception e) {
                        if (!fetchSuccess) {
                %>
                    <tr>
                        <td colspan="7" class="px-6 py-6 text-center">
                             <div class="inline-flex items-center gap-2 text-red-400 bg-red-500/10 px-4 py-2 rounded-lg border border-red-500/20">
                                <i data-lucide="alert-circle" class="h-4 w-4"></i>
                                <span>Error loading data: <%= e.getMessage() %></span>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                    } finally {
                         if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                         if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
                         if (con != null) try { con.close(); } catch (SQLException ignore) {}
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

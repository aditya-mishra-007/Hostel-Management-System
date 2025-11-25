<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("student") == null) {
        response.sendRedirect("student_login.jsp");
        return;
    }

    // --- ROLL NUMBER RETRIEVAL ---
    String roll_no = null;
    if (session.getAttribute("student_roll") != null) {
        roll_no = (String) session.getAttribute("student_roll");
    } else if (session.getAttribute("student") != null && session.getAttribute("student") instanceof String) {
        roll_no = (String) session.getAttribute("student");
    }

    // --- TEMPORARY FALLBACK (For Testing UI) ---
    if (roll_no == null || roll_no.isEmpty() || "N/A".equals(roll_no)) {
        roll_no = "H4007";
    }

    String pageTitle = "Fee Payment Status";
    String message = "";
    String messageType = "";

    // Database connection parameters
    String url = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String username = "root";
    String password = "admin";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Fee variables
    double totalFee = 0.00;
    double paidAmount = 0.00;
    double balanceDue = 0.00;
    String dueDateStr = "N/A";
    String feeStatus = "N/A";
    boolean recordFound = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);

        // --- HANDLE PAYMENT INITIATION ---
        if ("initiate_payment".equals(request.getParameter("action"))) {
            // In a real app, this would redirect to a gateway
            message = "Gateway Connected. Redirecting...";
            messageType = "pending";
        }

        // --- FETCH FEE RECORD ---
        String query = "SELECT semester_fee, paid_amount, due_date, status FROM fee_records WHERE student_id = ? ORDER BY due_date DESC LIMIT 1";
        ps = conn.prepareStatement(query);
        ps.setString(1, roll_no);
        rs = ps.executeQuery();

        if (rs.next()) {
            recordFound = true;
            totalFee = rs.getDouble("semester_fee");
            paidAmount = rs.getDouble("paid_amount");
            Date dueDate = rs.getDate("due_date");
            feeStatus = rs.getString("status");

            balanceDue = totalFee - paidAmount;
            if (balanceDue < 0) balanceDue = 0.00;

            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM, yyyy");
            dueDateStr = sdf.format(dueDate);

            // Logic Adjustment
            if (balanceDue == 0) {
                feeStatus = "PAID";
            } else if (dueDate != null && dueDate.before(new Date())) {
                feeStatus = "OVERDUE";
            } else {
                feeStatus = (paidAmount > 0) ? "PARTIAL" : "PENDING";
            }
        }

    } catch(Exception e){
        message = "System Error: " + e.getMessage();
        messageType = "error";
    } finally {
        try { if(rs != null) rs.close(); } catch(Exception ignored) {}
        try { if(ps != null) ps.close(); } catch(Exception ignored) {}
        try { if(conn != null) conn.close(); } catch(Exception ignored) {}
    }

    // --- UI SIMULATION FOR TESTING (Remove in Production) ---
    if (!recordFound && "H4007".equals(roll_no) && !"error".equals(messageType)) {
        recordFound = true;
        totalFee = 50000.00;
        paidAmount = 25000.00; // Simulating Partial Payment
        balanceDue = 25000.00;
        dueDateStr = "15 Dec, 2023";
        feeStatus = "PENDING";
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
            background-color: #0b0f19;
            /* Student Theme Background Gradient */
            background-image:
                radial-gradient(circle at 90% 10%, rgba(168, 85, 247, 0.15) 0%, transparent 40%),
                radial-gradient(circle at 10% 90%, rgba(99, 102, 241, 0.15) 0%, transparent 40%);
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

        .glass-panel {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }
        .glass-panel:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }

        /* --- STATUS BADGES --- */
        .status-PAID {
            background: rgba(34, 197, 94, 0.1); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.2); box-shadow: 0 0 15px rgba(34, 197, 94, 0.1);
        }
        .status-PENDING, .status-PARTIAL {
            background: rgba(245, 158, 11, 0.1); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.2); box-shadow: 0 0 15px rgba(245, 158, 11, 0.1);
        }
        .status-OVERDUE {
            background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); box-shadow: 0 0 15px rgba(239, 68, 68, 0.1);
        }

        /* --- GLOW TEXT --- */
        .text-glow-red { text-shadow: 0 0 20px rgba(248, 113, 113, 0.4); }
        .text-glow-green { text-shadow: 0 0 20px rgba(74, 222, 128, 0.4); }

        /* --- PAYMENT BUTTON --- */
        .pay-btn {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            transition: all 0.3s ease;
        }
        .pay-btn:hover {
            box-shadow: 0 0 20px rgba(245, 158, 11, 0.4);
            transform: translateY(-2px);
        }

    </style>
</head>

<body class="flex flex-col items-center justify-center min-h-screen p-4 sm:p-6">

<div class="w-full max-w-2xl animate-fade-in-up">

    <!-- Header -->
    <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center h-16 w-16 rounded-2xl bg-gradient-to-br from-indigo-500/20 to-purple-500/20 border border-white/10 mb-4 shadow-lg shadow-indigo-500/10">
            <i data-lucide="wallet" class="h-8 w-8 text-indigo-400"></i>
        </div>
        <h2 class="text-4xl font-bold text-white tracking-tight">Payments</h2>
        <div class="mt-2 inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/5 border border-white/10">
            <i data-lucide="user" class="h-3 w-3 text-slate-400"></i>
            <span class="text-sm font-mono text-slate-300"><%= roll_no %></span>
        </div>
    </div>

    <!-- Message Alert (HUD Style) -->
    <% if (!message.isEmpty()) { %>
        <div class="mb-6 p-4 rounded-xl flex items-center gap-3 border backdrop-blur-md shadow-lg
            <% if ("pending".equals(messageType)) { %> bg-yellow-500/10 border-yellow-500/20 text-yellow-400
            <% } else { %> bg-red-500/10 border-red-500/20 text-red-400 <% } %>">

            <% if ("pending".equals(messageType)) { %>
                <i data-lucide="loader-2" class="h-5 w-5 animate-spin"></i>
            <% } else { %>
                <i data-lucide="alert-triangle" class="h-5 w-5"></i>
            <% } %>
            <p class="font-medium text-sm"><%= message %></p>
        </div>
    <% } %>


    <% if (!recordFound) { %>
        <!-- No Record State -->
        <div class="glass-card p-10 rounded-2xl text-center border-dashed border-2 border-slate-700">
            <div class="h-16 w-16 bg-slate-800 rounded-full flex items-center justify-center mx-auto mb-4">
                <i data-lucide="file-x" class="h-8 w-8 text-slate-500"></i>
            </div>
            <h3 class="text-xl font-bold text-white">No Dues Found</h3>
            <p class="text-slate-400 mt-2 text-sm">There are no active fee records attached to your roll number.</p>
        </div>

    <% } else { %>

        <!-- Main Invoice Card -->
        <div class="glass-card rounded-3xl overflow-hidden relative">

            <!-- Top Status Bar -->
            <div class="p-6 border-b border-white/5 flex justify-between items-start">
                <div>
                    <p class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Fee Statement</p>
                    <p class="text-white font-medium text-sm flex items-center gap-2">
                        <i data-lucide="calendar" class="h-4 w-4 text-indigo-400"></i>
                        Due: <%= dueDateStr %>
                    </p>
                </div>
                <span class="px-3 py-1 rounded-lg text-xs font-bold uppercase tracking-wider <%= "status-" + feeStatus %>">
                    <%= feeStatus %>
                </span>
            </div>

            <!-- Financials Grid -->
            <div class="p-6 grid grid-cols-2 gap-4">

                <!-- Total Fee -->
                <div class="glass-panel p-4 rounded-xl">
                    <p class="text-xs font-bold text-slate-500 uppercase">Total Semester Fee</p>
                    <p class="text-xl font-bold text-slate-200 mt-1">₹<%= String.format("%,.0f", totalFee) %></p>
                </div>

                <!-- Paid Amount -->
                <div class="glass-panel p-4 rounded-xl">
                    <p class="text-xs font-bold text-slate-500 uppercase">Amount Paid</p>
                    <p class="text-xl font-bold text-emerald-400 mt-1">₹<%= String.format("%,.0f", paidAmount) %></p>
                </div>

                <!-- Main Balance Display -->
                <div class="col-span-2 mt-2 p-6 rounded-2xl bg-gradient-to-br from-slate-900/50 to-slate-800/50 border border-white/5 text-center">
                    <p class="text-sm font-medium text-slate-400 mb-2 flex items-center justify-center gap-2">
                        <i data-lucide="scale" class="h-4 w-4"></i> Current Balance Due
                    </p>
                    <p class="text-5xl font-black tracking-tight <%= balanceDue > 0 ? "text-red-400 text-glow-red" : "text-emerald-400 text-glow-green" %>">
                        ₹<%= String.format("%,.0f", balanceDue) %>
                    </p>
                </div>
            </div>

            <!-- Action Area -->
            <div class="p-6 pt-0">
                <% if ("PAID".equals(feeStatus)) { %>
                    <!-- Download Receipt -->
                    <button onclick="alert('Downloading Receipt...')" class="w-full py-4 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold flex items-center justify-center gap-2 transition-all shadow-lg shadow-emerald-900/20 group">
                        <i data-lucide="download" class="h-5 w-5 group-hover:-translate-y-1 transition-transform"></i>
                        Download Receipt
                    </button>
                <% } else if (balanceDue > 0) { %>
                    <!-- Pay Now -->
                    <form method="post">
                        <input type="hidden" name="action" value="initiate_payment">
                        <button type="submit" class="pay-btn w-full py-4 rounded-xl text-white font-bold flex items-center justify-center gap-2 group">
                            <i data-lucide="zap" class="h-5 w-5 group-hover:scale-110 transition-transform"></i>
                            Pay ₹<%= String.format("%,.0f", balanceDue) %> Now
                        </button>
                    </form>

                    <!-- Payment Methods -->
                    <div class="mt-6">
                        <p class="text-center text-xs font-bold text-slate-500 uppercase tracking-widest mb-4">Or pay via</p>
                        <div class="grid grid-cols-3 gap-3">
                            <button class="glass-panel p-3 rounded-xl flex flex-col items-center gap-2 group">
                                <i data-lucide="landmark" class="h-6 w-6 text-blue-400 group-hover:scale-110 transition-transform"></i>
                                <span class="text-[10px] font-bold text-slate-400 group-hover:text-white">NetBanking</span>
                            </button>
                            <button class="glass-panel p-3 rounded-xl flex flex-col items-center gap-2 group">
                                <i data-lucide="qr-code" class="h-6 w-6 text-teal-400 group-hover:scale-110 transition-transform"></i>
                                <span class="text-[10px] font-bold text-slate-400 group-hover:text-white">UPI / QR</span>
                            </button>
                            <button class="glass-panel p-3 rounded-xl flex flex-col items-center gap-2 group">
                                <i data-lucide="credit-card" class="h-6 w-6 text-purple-400 group-hover:scale-110 transition-transform"></i>
                                <span class="text-[10px] font-bold text-slate-400 group-hover:text-white">Card</span>
                            </button>
                        </div>
                    </div>
                <% } %>
            </div>

        </div>

    <% } %>

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

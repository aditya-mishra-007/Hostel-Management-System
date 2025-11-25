<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hostel Management Portal - Select Role</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0b0f19; /* Very dark midnight */
            background-image:
                radial-gradient(circle at 50% 0%, #1e293b 0%, transparent 70%),
                radial-gradient(circle at 100% 100%, #1e1b4b 0%, transparent 50%);
            min-height: 100vh;
        }

        h1, h2, h3 {
            font-family: 'Space Grotesk', sans-serif; /* Techy Heading Font */
        }

        /* --- THE GLASS CARD --- */
        .main-card {
            background: rgba(17, 24, 39, 0.7); /* Darker, clearer glass */
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08); /* Subtle, crisp border */
            box-shadow: 0 0 0 1px rgba(0,0,0,0.2), 0 20px 40px -10px rgba(0,0,0,0.5);
        }

        /* --- INTERACTIVE ROLE CARDS --- */
        .role-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.08); /* Default quiet border */
            transition: all 0.3s ease-out;
            position: relative;
            overflow: hidden;
        }

        /* Hover State: Admin (Cyan Theme) */
        .role-card.admin-theme:hover {
            border-color: #06b6d4; /* Cyan 500 */
            background: rgba(6, 182, 212, 0.05); /* Very subtle tint */
            box-shadow: 0 0 20px rgba(6, 182, 212, 0.15); /* Sharp glow */
            transform: translateY(-2px);
        }

        /* Hover State: Student (Violet Theme) */
        .role-card.student-theme:hover {
            border-color: #a855f7; /* Purple 500 */
            background: rgba(168, 85, 247, 0.05);
            box-shadow: 0 0 20px rgba(168, 85, 247, 0.15);
            transform: translateY(-2px);
        }

        /* Icon Background transition */
        .icon-box {
            transition: all 0.3s ease;
        }
        .admin-theme:hover .icon-box {
            background-color: rgba(6, 182, 212, 0.2);
            color: #22d3ee;
        }
        .student-theme:hover .icon-box {
            background-color: rgba(168, 85, 247, 0.2);
            color: #d8b4fe;
        }

        /* Arrow Movement */
        .arrow-icon {
            transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .role-card:hover .arrow-icon {
            transform: translateX(4px);
        }

    </style>
</head>
<body class="flex items-center justify-center p-4">

    <div class="w-full max-w-lg main-card rounded-3xl p-8 sm:p-10 relative">

        <div class="absolute top-0 left-1/2 transform -translate-x-1/2 w-1/3 h-1 bg-gradient-to-r from-transparent via-blue-500 to-transparent opacity-70"></div>

        <header class="text-center mb-10">
            <div class="inline-flex items-center justify-center mb-6">
                <div class="p-3 bg-blue-500/10 rounded-2xl border border-blue-500/20">
                    <i data-lucide="building-2" class="h-8 w-8 text-blue-400"></i>
                </div>
            </div>
            <h1 class="text-4xl font-bold text-white mb-2 tracking-tight">Hostel Portal</h1>
            <p class="text-slate-400 text-sm">Please identify your role to proceed</p>
        </header>

        <div class="space-y-4">

            <a href="admin_login.jsp" class="role-card admin-theme flex items-center justify-between p-5 rounded-xl group cursor-pointer">
                <div class="flex items-center gap-5">
                    <div class="icon-box h-12 w-12 rounded-lg bg-slate-800 border border-slate-700 flex items-center justify-center text-slate-400">
                        <i data-lucide="shield-check" class="h-6 w-6"></i>
                    </div>
                    <div class="flex flex-col">
                        <span class="text-lg font-bold text-slate-100 group-hover:text-cyan-400 transition-colors">Admin Login</span>
                        <span class="text-xs text-slate-500 group-hover:text-cyan-200/70 transition-colors">Manage Residents & Staff</span>
                    </div>
                </div>
                <i data-lucide="chevron-right" class="arrow-icon h-5 w-5 text-slate-600 group-hover:text-cyan-400"></i>
            </a>

            <a href="student_login.jsp" class="role-card student-theme flex items-center justify-between p-5 rounded-xl group cursor-pointer">
                <div class="flex items-center gap-5">
                    <div class="icon-box h-12 w-12 rounded-lg bg-slate-800 border border-slate-700 flex items-center justify-center text-slate-400">
                        <i data-lucide="user" class="h-6 w-6"></i>
                    </div>
                    <div class="flex flex-col">
                        <span class="text-lg font-bold text-slate-100 group-hover:text-purple-400 transition-colors">Student Login</span>
                        <span class="text-xs text-slate-500 group-hover:text-purple-200/70 transition-colors">View Status & Requests</span>
                    </div>
                </div>
                <i data-lucide="chevron-right" class="arrow-icon h-5 w-5 text-slate-600 group-hover:text-purple-400"></i>
            </a>

        </div>

        <div class="mt-8 text-center border-t border-slate-800 pt-6">
            <p class="text-xs text-slate-600 font-medium">SECURE SYSTEM VER 1.0</p>
        </div>

    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>

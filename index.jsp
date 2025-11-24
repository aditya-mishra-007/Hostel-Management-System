<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hostel Management Portal - Login Selection</title>
    <!-- Load Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Load Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        /* Define a custom font and root colors */
        :root {
            --color-brand: #1d4ed8; /* Blue 700 */
            --color-admin: #0d9488; /* Teal 600 */
            --color-student: #4f46e5; /* Indigo 600 */
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6; /* Light gray background */
        }
        .card-shadow {
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card-shadow:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4">

    <!-- Main Container -->
    <div class="w-full max-w-xl bg-white p-8 sm:p-12 rounded-2xl card-shadow border-t-8 border-blue-700">

        <!-- Header Section -->
        <header class="text-center mb-10">
            <div class="flex justify-center items-center mb-3">
                <!-- University/Hostel Icon -->
                <i data-lucide="building-2" class="h-10 w-10 text-blue-700"></i>
            </div>
            <h1 class="text-3xl sm:text-4xl font-extrabold text-gray-900">
                Hostel Management Portal
            </h1>
            <p class="mt-2 text-md text-gray-500">
                Select your role to access the system dashboard.
            </p>
        </header>

        <!-- Role Selection Cards -->
        <div class="space-y-6">

            <!-- Admin Login Card -->
            <a href="admin_login.jsp" class="role-card flex items-center justify-between p-6 bg-white border border-gray-200 rounded-xl shadow-lg hover:bg-teal-50 card-shadow hover:border-teal-400 group">
                <div class="flex items-center space-x-4">
                    <i data-lucide="shield-check" class="h-8 w-8 text-teal-600 group-hover:scale-105 transition-transform"></i>
                    <div>
                        <h3 class="text-xl font-bold text-gray-800 group-hover:text-teal-700">Admin Login</h3>
                        <p class="text-sm text-gray-500">Hostel Authority and System Management</p>
                    </div>
                </div>
                <i data-lucide="arrow-right" class="h-6 w-6 text-teal-600 group-hover:translate-x-1 transition-transform"></i>
            </a>

            <!-- Student Login Card -->
            <a href="student_login.jsp" class="role-card flex items-center justify-between p-6 bg-white border border-gray-200 rounded-xl shadow-lg hover:bg-indigo-50 card-shadow hover:border-indigo-400 group">
                <div class="flex items-center space-x-4">
                    <i data-lucide="user-square" class="h-8 w-8 text-indigo-600 group-hover:scale-105 transition-transform"></i>
                    <div>
                        <h3 class="text-xl font-bold text-gray-800 group-hover:text-indigo-700">Student Login</h3>
                        <p class="text-sm text-gray-500">Room Status, Leave Requests, and Fees</p>
                    </div>
                </div>
                <i data-lucide="arrow-right" class="h-6 w-6 text-indigo-600 group-hover:translate-x-1 transition-transform"></i>
            </a>

        </div>

        <!-- Footer / System Info -->
        <footer class="mt-10 pt-6 border-t border-gray-200 text-center">
            <p class="text-xs text-gray-400">
                Secure Hostel Management System - Version 1.0
            </p>
        </footer>

    </div>

    <!-- Re-initialize Lucide Icons -->
    <script>
        lucide.createIcons();
    </script>

</body>
</html>
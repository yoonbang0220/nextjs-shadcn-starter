import Link from "next/link"
import { LayoutDashboard, Users, Settings, BarChart3, FileText } from "lucide-react"

const sidebarItems = [
  { href: "/dashboard", icon: LayoutDashboard, label: "개요" },
  { href: "/dashboard/analytics", icon: BarChart3, label: "분석" },
  { href: "/dashboard/users", icon: Users, label: "사용자" },
  { href: "/dashboard/posts", icon: FileText, label: "게시물" },
  { href: "/dashboard/settings", icon: Settings, label: "설정" },
]

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex min-h-[calc(100vh-8rem)]">
      {/* 사이드바 */}
      <aside className="w-56 border-r bg-muted/30 shrink-0">
        <nav className="flex flex-col gap-1 p-4">
          <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wider px-3 mb-2">
            메뉴
          </p>
          {sidebarItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="flex items-center gap-3 px-3 py-2 rounded-md text-sm text-foreground/70 hover:text-foreground hover:bg-muted transition-colors"
            >
              <item.icon className="h-4 w-4 shrink-0" />
              {item.label}
            </Link>
          ))}
        </nav>
      </aside>

      {/* 콘텐츠 영역 */}
      <div className="flex-1 overflow-auto">
        {children}
      </div>
    </div>
  )
}

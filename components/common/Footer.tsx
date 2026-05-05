export function Footer() {
  return (
    <footer className="border-t py-8 mt-auto">
      <div className="max-w-7xl mx-auto px-4 flex flex-col md:flex-row items-center justify-between gap-4 text-sm text-muted-foreground">
        <p>© 2026 StarterKit. All rights reserved.</p>
        <div className="flex gap-6">
          <a href="#" className="hover:text-foreground transition-colors">
            이용약관
          </a>
          <a href="#" className="hover:text-foreground transition-colors">
            개인정보처리방침
          </a>
          <a href="#" className="hover:text-foreground transition-colors">
            문의하기
          </a>
        </div>
      </div>
    </footer>
  )
}

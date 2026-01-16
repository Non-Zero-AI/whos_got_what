import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <main>
      {/* Navigation */}
      <nav style={{ padding: '24px 0', position: 'sticky', top: 0, background: 'var(--bg-color)', zIndex: 100, borderBottom: '1px solid var(--border)' }}>
        <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Link href="/" style={{ fontSize: '20px', fontWeight: 800, letterSpacing: '-0.04em' }}>
            Who's Got What
          </Link>
          <div style={{ display: 'flex', gap: '32px', alignItems: 'center' }}>
            <Link href="#features" className="text-secondary" style={{ fontSize: '14px', fontWeight: 500 }}>Features</Link>
            <Link href="/privacy" className="text-secondary" style={{ fontSize: '14px', fontWeight: 500 }}>Privacy</Link>
            <Link href="/terms" className="text-secondary" style={{ fontSize: '14px', fontWeight: 500 }}>Terms</Link>
            <Link href="https://example.com" className="button button-primary" style={{ fontSize: '14px', padding: '8px 16px' }}>Download</Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section style={{ padding: '120px 0 80px', textAlign: 'center' }} className="matte-gradient">
        <div className="container">
          <h1 style={{ fontSize: '64px', marginBottom: '24px', lineHeight: 1.1 }}>
            Discover What’s Happening <br />
            <span style={{ color: 'var(--accent)' }}>Around Town.</span>
          </h1>
          <p style={{ fontSize: '20px', color: 'var(--text-secondary)', maxWidth: '600px', margin: '0 auto 40px', lineHeight: 1.5 }}>
            The ultimate community hub for local events, exclusive business deals, and everything happening in your neighborhood.
          </p>
          <div style={{ display: 'flex', gap: '16px', justifyContent: 'center' }}>
            <Link href="#" className="button button-primary">App Store</Link>
            <Link href="#" className="button button-secondary">Play Store</Link>
          </div>

          <div style={{ marginTop: '80px', position: 'relative' }}>
            <div style={{
              width: '100%',
              height: 'auto',
              minHeight: '500px',
              background: 'var(--surface-secondary)',
              borderRadius: 'var(--radius-l)',
              boxShadow: 'var(--elevation-3)',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}>
              <Image
                src="/hero.png"
                alt="Who's Got What App Preview"
                width={1200}
                height={675}
                style={{ width: '100%', height: 'auto', display: 'block' }}
                priority
              />
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" style={{ padding: '100px 0' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: '64px' }}>
            <h2 style={{ fontSize: '36px', marginBottom: '16px' }}>Everything you need to stay connected</h2>
            <p style={{ color: 'var(--text-secondary)' }}>Powerful features designed for locals and businesses alike.</p>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '32px' }}>
            <div className="card">
              <div style={{ width: '48px', height: '48px', background: 'var(--accent-soft)', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px' }}>
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
              </div>
              <h3 style={{ marginBottom: '12px' }}>Home Feed</h3>
              <p style={{ color: 'var(--text-secondary)', lineHeight: 1.6 }}>A personalized stream of events, news, and updates happening in your immediate area.</p>
            </div>

            <div className="card">
              <div style={{ width: '48px', height: '48px', background: 'var(--accent-soft)', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px' }}>
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="3 6 9 3 15 6 21 3 21 18 15 21 9 18 3 21"></polygon><line x1="9" y1="18" x2="9" y2="3"></line><line x1="15" y1="21" x2="15" y2="6"></line></svg>
              </div>
              <h3 style={{ marginBottom: '12px' }}>Map View</h3>
              <p style={{ color: 'var(--text-secondary)', lineHeight: 1.6 }}>Visualize local happenings on an interactive map. Find exactly what's close to you.</p>
            </div>

            <div className="card">
              <div style={{ width: '48px', height: '48px', background: 'var(--accent-soft)', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px' }}>
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
              </div>
              <h3 style={{ marginBottom: '12px' }}>Business Plans</h3>
              <p style={{ color: 'var(--text-secondary)', lineHeight: 1.6 }}>Exclusive tools for businesses to reach the community, post deals, and grow their presence.</p>
            </div>
          </div>
          <div style={{ marginTop: '80px', textAlign: 'center' }}>
            <Image
              src="/features.png"
              alt="App Features"
              width={1000}
              height={562}
              style={{ width: '100%', maxWidth: '1000px', height: 'auto', borderRadius: 'var(--radius-l)' }}
            />
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section style={{ padding: '100px 0', borderTop: '1px solid var(--border)' }}>
        <div className="container">
          <div style={{
            background: 'var(--accent)',
            padding: '80px',
            borderRadius: 'var(--radius-l)',
            textAlign: 'center',
            color: '#ffffff'
          }}>
            <h2 style={{ fontSize: '42px', marginBottom: '24px' }}>Ready to discover your town?</h2>
            <p style={{ fontSize: '18px', opacity: 0.9, marginBottom: '40px', maxWidth: '500px', margin: '0 auto 40px' }}>
              Join thousands of locals staying informed and connected with Who's Got What.
            </p>
            <div style={{ display: 'flex', gap: '16px', justifyContent: 'center' }}>
              <Link href="#" className="button button-secondary" style={{ background: '#ffffff', color: 'var(--accent)', border: 'none' }}>Download Now</Link>
              <Link href="#" className="button" style={{ border: '1px solid rgba(255,255,255,0.3)', color: '#ffffff' }}>Business Portal</Link>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer style={{ padding: '80px 0 40px', background: 'var(--surface-secondary)', borderTop: '1px solid var(--border)' }}>
        <div className="container">
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '60px' }}>
            <div style={{ maxWidth: '300px' }}>
              <div style={{ fontSize: '20px', fontWeight: 800, letterSpacing: '-0.04em', marginBottom: '16px' }}>Who's Got What</div>
              <p style={{ color: 'var(--text-secondary)', fontSize: '14px', lineHeight: 1.6 }}>
                The ultimate community hub for local events, business deals, and town happenings.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '80px' }}>
              <div>
                <h4 style={{ marginBottom: '20px', fontSize: '14px', textTransform: 'uppercase', letterSpacing: '0.1em' }}>Product</h4>
                <ul style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  <li><Link href="#features" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>Features</Link></li>
                  <li><Link href="#" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>Download</Link></li>
                </ul>
              </div>
              <div>
                <h4 style={{ marginBottom: '20px', fontSize: '14px', textTransform: 'uppercase', letterSpacing: '0.1em' }}>Legal</h4>
                <ul style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  <li><Link href="/privacy" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>Privacy Policy</Link></li>
                  <li><Link href="/terms" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>User Agreement</Link></li>
                </ul>
              </div>
            </div>
          </div>
          <div style={{ paddingTop: '40px', borderTop: '1px solid var(--border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <p style={{ color: 'var(--text-tertiary)', fontSize: '12px' }}>&copy; {new Date().getFullYear()} Who's Got What. All rights reserved.</p>
            <div style={{ display: 'flex', gap: '20px' }}>
              <Link href="#" style={{ color: 'var(--text-tertiary)', fontSize: '12px' }}>Twitter</Link>
              <Link href="#" style={{ color: 'var(--text-tertiary)', fontSize: '12px' }}>Instagram</Link>
            </div>
          </div>
        </div>
      </footer>
    </main>
  );
}

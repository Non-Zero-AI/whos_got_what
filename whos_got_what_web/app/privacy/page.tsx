import Link from "next/link";

export default function PrivacyPolicy() {
    return (
        <main>
            {/* Navigation */}
            <nav style={{ padding: '24px 0', borderBottom: '1px solid var(--border)' }}>
                <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Link href="/" style={{ fontSize: '20px', fontWeight: 800, letterSpacing: '-0.04em' }}>
                        Who's Got What
                    </Link>
                    <Link href="/" className="button button-secondary" style={{ fontSize: '14px', padding: '8px 16px' }}>Back to Home</Link>
                </div>
            </nav>

            <section style={{ padding: '80px 0' }}>
                <div className="container" style={{ maxWidth: '800px' }}>
                    <h1 style={{ fontSize: '48px', marginBottom: '32px' }}>Privacy Policy</h1>
                    <p style={{ color: 'var(--text-tertiary)', marginBottom: '48px' }}>Last Updated: January 15, 2026</p>

                    <div style={{ display: 'flex', flexDirection: 'column', gap: '40px', lineHeight: 1.6 }}>
                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>1. Introduction</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                Welcome to Who's Got What ("we," "our," or "us"). We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and share information about you when you use our mobile application and website.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>2. Data We Collect</h2>
                            <p style={{ color: 'var(--text-secondary)', marginBottom: '16px' }}>
                                We collect information you provide directly to us, including:
                            </p>
                            <ul style={{ color: 'var(--text-secondary)', display: 'flex', flexDirection: 'column', gap: '8px', paddingLeft: '20px', listStyle: 'disc' }}>
                                <li><strong>Personal Identifiers:</strong> Name, email address, and phone number.</li>
                                <li><strong>Business Information:</strong> Business names, descriptions, and contact details.</li>
                                <li><strong>Event Data:</strong> Details about events you post, including titles, descriptions, and times.</li>
                                <li><strong>Location Data:</strong> Precise or approximate location information if you grant us permission to access it.</li>
                            </ul>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>3. How We Use Your Data</h2>
                            <p style={{ color: 'var(--text-secondary)', marginBottom: '16px' }}>
                                We use the information we collect to:
                            </p>
                            <ul style={{ color: 'var(--text-secondary)', display: 'flex', flexDirection: 'column', gap: '8px', paddingLeft: '20px', listStyle: 'disc' }}>
                                <li>Provide, maintain, and improve our services.</li>
                                <li>Personalize your experience and show you relevant local events and deals.</li>
                                <li>Process transactions and manage subscriptions.</li>
                                <li>Communicate with you about updates, security alerts, and support.</li>
                                <li>Anonymized analytics to understand how users interact with our app.</li>
                            </ul>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>4. Third-Party Tools</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                We use third-party services for analytics, storage, and marketing, including Supabase (data storage and authentication), Stripe (payment processing), and Google Analytics. These third parties may access your data only to perform specific tasks on our behalf and are obligated not to disclose or use it for any other purpose.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>5. User Rights (GDPR & CCPA)</h2>
                            <p style={{ color: 'var(--text-secondary)', marginBottom: '16px' }}>
                                Depending on your location, you may have the following rights regarding your personal data:
                            </p>
                            <ul style={{ color: 'var(--text-secondary)', display: 'flex', flexDirection: 'column', gap: '8px', paddingLeft: '20px', listStyle: 'disc' }}>
                                <li><strong>Access:</strong> The right to request a copy of the data we hold about you.</li>
                                <li><strong>Correction:</strong> The right to request that we correct any inaccurate information.</li>
                                <li><strong>Deletion:</strong> The right to request that we delete your personal data.</li>
                                <li><strong>Export:</strong> The right to request your data in a portable, machine-readable format.</li>
                            </ul>
                            <p style={{ color: 'var(--text-secondary)', marginTop: '16px' }}>
                                To exercise any of these rights, please contact us at privacy@whosgotwhat.app.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>6. Data Security</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                We implement industry-standard security measures to protect your data. However, no method of transmission over the Internet or electronic storage is 100% secure, and we cannot guarantee absolute security.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>7. Changes to This Policy</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.
                            </p>
                        </section>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer style={{ padding: '60px 0', borderTop: '1px solid var(--border)', textAlign: 'center' }}>
                <div className="container">
                    <p style={{ color: 'var(--text-tertiary)', fontSize: '14px' }}>&copy; {new Date().getFullYear()} Who's Got What. All rights reserved.</p>
                </div>
            </footer>
        </main>
    );
}

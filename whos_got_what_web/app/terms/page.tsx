import Link from "next/link";

export default function UserAgreement() {
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
                    <h1 style={{ fontSize: '48px', marginBottom: '32px' }}>User Agreement</h1>
                    <p style={{ color: 'var(--text-tertiary)', marginBottom: '48px' }}>Last Updated: January 15, 2026</p>

                    <div style={{ display: 'flex', flexDirection: 'column', gap: '40px', lineHeight: 1.6 }}>
                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>1. Acceptance of Terms</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                By accessing or using the Who's Got What app and website, you agree to be bound by this User Agreement and our Privacy Policy. If you do not agree to these terms, please do not use our services.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>2. Posting Policies & Prohibited Content</h2>
                            <p style={{ color: 'var(--text-secondary)', marginBottom: '16px' }}>
                                Users are responsible for the content they post. You agree not to post content that:
                            </p>
                            <ul style={{ color: 'var(--text-secondary)', display: 'flex', flexDirection: 'column', gap: '8px', paddingLeft: '20px', listStyle: 'disc' }}>
                                <li>Is illegal, threatening, defamatory, or invasive of privacy.</li>
                                <li>Infringes on intellectual property rights.</li>
                                <li>Contains software viruses or any other computer code designed to interrupt or limit functionality.</li>
                                <li>Is misleading or contains fraudulent business offers.</li>
                                <li>Promotes hate speech or discrimination.</li>
                            </ul>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>3. Payment Terms & Refund Policy</h2>
                            <p style={{ color: 'var(--text-secondary)', marginBottom: '16px' }}>
                                Certain features of Who's Got What, such as Business Plans, require payment.
                            </p>
                            <ul style={{ color: 'var(--text-secondary)', display: 'flex', flexDirection: 'column', gap: '8px', paddingLeft: '20px', listStyle: 'disc' }}>
                                <li><strong>Subscription Billing:</strong> Payments are processed via Stripe. Subscriptions renew automatically unless cancelled.</li>
                                <li><strong>Refunds:</strong> All sales are final. Refunds are granted at our sole discretion, typically only in cases of technical error or as required by law.</li>
                                <li><strong>Pricing:</strong> We reserve the right to change our pricing at any time with notice to users.</li>
                            </ul>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>4. Liability & Usage Limitations</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                Who's Got What is provided "as is" without any warranties. We are not liable for any damages arising from your use of the service, including but not limited to direct, indirect, incidental, or consequential damages. We do not guarantee the accuracy of user-posted content or event details.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>5. Data Collection & Analytics Consent</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                By using our services, you consent to the collection and use of your data as described in our Privacy Policy, including the use of third-party analytics tools to improve the service and personalize your experience.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>6. Professional Advice Disclaimer</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                Information provided on Who's Got What is for informational purposes only and does not constitute professional, legal, or financial advice.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>7. Governing Jurisdiction</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                This agreement is governed by the laws of the jurisdiction in which our company is headquartered, without regard to its conflict of law principles.
                            </p>
                        </section>

                        <section>
                            <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>8. Contact Information</h2>
                            <p style={{ color: 'var(--text-secondary)' }}>
                                If you have any questions about this User Agreement, please contact us at support@whosgotwhat.app.
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

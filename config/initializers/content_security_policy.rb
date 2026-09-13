# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src    :self, :https
    policy.font_src       :self, :https, :data
    policy.img_src        :self, :https, :data
    policy.object_src     :none
    policy.script_src     :self, :https
    policy.style_src      :self, :https
    # Chart.js (via chartkick) sizes its canvas by setting inline style="..." attributes in
    # JS - CSP nonces can't cover attributes (only <script>/<style> elements), so this is the
    # only way to allow it without loosening style_src itself (which governs <style> elements).
    policy.style_src_attr :unsafe_inline
    # Specify URI for violation reports
    policy.report_uri "/csp-violation-report-endpoint"
  end

  # Ties the nonce to the session (persisted on first read, reused after) rather than a fresh
  # random value per request. Turbo Frame updates fetch new HTML into the *same* still-open
  # document, which keeps enforcing the CSP nonce from the original full-page load - a
  # per-request random nonce would never match that, so any inline <script> rendered into a
  # frame response (e.g. Chartkick's chart-drawing script) would always be silently blocked.
  # (request.session.id alone can be blank on a visitor's very first request, before anything
  # else forces the session to persist - reading/writing a session value here forces it early.)
  config.content_security_policy_nonce_generator = ->(request) {
    request.session[:content_security_policy_nonce] ||= SecureRandom.base64(16)
  }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end

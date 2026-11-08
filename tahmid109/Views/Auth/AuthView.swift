import SwiftUI

/// Clean and simple authentication screen for TodoApp109.
struct AuthView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 20)

                // App Brand & Logo
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.12))
                            .frame(width: 80, height: 80)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(AppTheme.primary)
                    }

                    Text("TodoApp109")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.text)

                    Text("Simple & reliable task management")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                // Auth Mode Switcher (Sign In vs Create Account)
                Picker("Authentication Mode", selection: $viewModel.isRegister) {
                    Text("Sign In").tag(false)
                    Text("Create Account").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 420)

                // Input Card
                VStack(spacing: 16) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.secondaryText)

                        TextField("you@example.com", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(12)
                            .background(AppTheme.inputBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(AppTheme.separator, lineWidth: 1)
                            )
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.secondaryText)

                        HStack {
                            Group {
                                if viewModel.showPassword {
                                    TextField("At least 6 characters", text: $viewModel.password)
                                } else {
                                    SecureField("At least 6 characters", text: $viewModel.password)
                                }
                            }
                            .textContentType(viewModel.isRegister ? .newPassword : .password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                            Button {
                                viewModel.togglePasswordVisibility()
                            } label: {
                                Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            .accessibilityLabel(viewModel.showPassword ? "Hide password" : "Show password")
                        }
                        .padding(12)
                        .background(AppTheme.inputBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.separator, lineWidth: 1)
                        )
                    }

                    // Firebase status notice
                    if !appViewModel.configured {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(AppTheme.primary)
                                .font(.subheadline)
                            Text("GoogleService-Info.plist is not yet added. You can use the local demo mode below.")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(10)
                        .background(AppTheme.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    }

                    // Submit Action Button
                    PaperButton(
                        title: viewModel.isRegister ? "Create Account" : "Sign In",
                        icon: "arrow.right",
                        busy: appViewModel.saving
                    ) {
                        Task {
                            await viewModel.submit(with: appViewModel)
                        }
                    }
                    .disabled(!appViewModel.configured || !viewModel.canSubmit)
                    .opacity(!appViewModel.configured || !viewModel.canSubmit ? 0.5 : 1)

                    // Forgot Password Button
                    if !viewModel.isRegister && appViewModel.configured {
                        Button("Forgot password?") {
                            Task {
                                await viewModel.resetPassword(with: appViewModel)
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(AppTheme.primary)
                        .disabled(viewModel.cleanEmail.isEmpty || appViewModel.saving)
                    }
                }
                .padding(20)
                .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(AppTheme.separator, lineWidth: 1)
                )
                .frame(maxWidth: 420)

                // Demo Mode Button
                Button {
                    appViewModel.startDemo()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.circle")
                        Text("Explore in Demo Mode")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.vertical, 8)
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .alert("Check your email", isPresented: $viewModel.resetEmailSent) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("If an account exists for this email, you will receive a password reset link.")
        }
    }
}

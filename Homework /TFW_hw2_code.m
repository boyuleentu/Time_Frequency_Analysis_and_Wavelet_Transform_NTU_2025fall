function y = recSTFT(x, t, f, B)
    % to column
    x = x(:); t = t(:); f = f(:);
    dt = t(2) - t(1);
    Nt = numel(t);

    % rectengular function
    Q = floor(B/dt);
    Nfft = 4096;%>2Q+1

    % freq resolution and axis
    df_fft  = 1/(Nfft*dt);
    f_fft_s = (-floor(Nfft/2):ceil(Nfft/2)-1).' * df_fft;

    m_idx = zeros(numel(f),1);
    for k = 1:numel(f)
        [~, m_idx(k)] = min(abs(f_fft_s - f(k)));
    end

    m_unshift = mod((m_idx-1) - floor(Nfft/2), Nfft) + 1;
    phase_m = exp(1j * 2*pi * ((m_unshift-1) * Q) / Nfft);

    % output
    y = complex(zeros(numel(f), Nt));

    % calculation
    for n = 1:Nt
        x1 = zeros(Nfft,1);
        k  = (-Q:Q).';
        p  = n + k;
        valid = (p >= 1) & (p <= Nt);
        q  = (k(valid) + Q) + 1;      % 1..L
        x1(q) = x(p(valid));

        % Nfft FFT
        X1 = fft(x1, Nfft);
        X1s = fftshift(X1);
        y(:, n) = phase_m .* X1s(m_idx);
    end
end

% Demo for recSTFT with centered frequency axis (-5..+5 Hz)
% parameters
Fs = 100;
dt = 1/Fs;
t  = (0:dt:30).';
x  = zeros(size(t));
x(t < 10)               = cos(2*pi*1*t(t < 10));
x(t >= 10 & t < 20)     = cos(2*pi*3*t(t >= 10 & t < 20));
x(t >= 20)              = cos(2*pi*2*t(t >= 20));
B = 0.5;
Nfft_target = 4096;
df = Fs / Nfft_target;
Fmax = 5;
f = (-Fmax : df : Fmax).';

% run STFT and calculate time
tic;
y = recSTFT(x, t, f, B);
elapsed = toc;
fprintf('Computation time: %.6f seconds\n', elapsed);

% plot
C = 400;
figure;
image(t, f, abs(y)/max(max(abs(y)))*C);
colormap(gray(256));
set(gca, 'YDir', 'normal');
set(gca, 'FontSize', 12);
xlabel('Time (Sec)', 'FontSize', 12);
ylabel('Frequency (Hz)', 'FontSize', 12);
title('STFT of x(t) with centered frequency axis', 'FontSize', 12);
colorbar;
ylim([-Fmax Fmax]);
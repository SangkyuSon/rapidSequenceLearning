function Wc = computeGramian(A,B,C)
% computeGramian  Finite-horizon controllability Gramian of a linear system.
%
%   Wc = computeGramian(A,B)   controllability Gramian of (A,B)
%   Wc = computeGramian(A,B,C) output controllability Gramian of (A,B,C)
%
%   The integral over the horizon T is approximated by a Riemann sum with
%   step dt. trace(Wc) is used as the scalar controllability of a channel.

T  = 1;
dt = 0.01;

if nargin == 2
    Wc = zeros(size(A));
else
    Wc = zeros(size(C,1));
end

for tau = 0:dt:T
    E = expm(A*tau);
    if nargin == 2
        Wc = Wc + E*(B*B')*E'*dt;
    else
        H  = C*E*B;
        Wc = Wc + H*H'*dt;
    end
end

end

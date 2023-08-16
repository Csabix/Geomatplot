function res = dist2bezier_matrix(pos,A,B,C)
% adapted from https://iquilezles.org/articles/distfunctions2d/
    function c = gdot(a,b)
        c = real(conj(a).*b);
    end
    function c = gdot2(a)
        c = gdot(a,a);
    end
    function v = clamp(x,a,b)
        v = min(max(x,a),b);
    end
    a = B - A;
    b = A - 2*B + C;
    c = a * 2;
    d = A - pos;
    kk = 1./gdot(b,b);
    kx = kk.*gdot(a,b);                    
    ky = kk.*(2*gdot(a,a)+gdot(d,b))/3;
    kz = kk.*gdot(d,a);                    
    p = ky - kx.*kx;                       
    p3 = p.*p.*p;                          
    q = kx.*(2*kx.*kx-3*ky) + kz;          
    h = q.*q + 4*p3;                       
    res = 0*ky;
    mask = h>=0;
    % if mask
        h = realsqrt(h(mask));
        q1 = 0.5*( h-q(mask));
        q2 = 0.5*(-h-q(mask));
        uv1 = sign(q1).*abs(q1).^(1/3);
        uv2 = sign(q2).*abs(q2).^(1/3); 
        t   = clamp( uv1+uv2-kx, 0, 1 );
        res(mask) = gdot2((c + b.*t).*t + d(mask));
    % else
        mask = ~mask;
        z  = realsqrt(-p(mask));               
        v  = acos( q(mask)./(p(mask).*z.*2) ) / 3;   
        m  = cos(v);                     
        n  = sin(v)*sqrt(3);             
        t1 = clamp( (m+m).*z-kx,0,1);    
        t2 = clamp(-(n+m).*z-kx,0,1);    
        q1 = (c+b.*t1).*t1 + d(mask);          
        q2 = (c+b.*t2).*t2 + d(mask);          
        res(mask) = min( gdot2(q1), gdot2(q2) );
    % end
    res = realsqrt(res);
end
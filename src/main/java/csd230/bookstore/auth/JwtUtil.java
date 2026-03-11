package csd230.bookstore.auth;

import io.jsonwebtoken.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Component
public class JwtUtil {
    private final String secret_key = "mysecretkey";

    /**
     * TEST SETTING:
     * Set this to 10 for expiration testing.
     * Set to 3600 for 1-hour session in a production-like environment.
     */
    private long accessTokenValidity = 10;

    private final JwtParser jwtParser;
    private final String TOKEN_HEADER = "Authorization";
    private final String TOKEN_PREFIX = "Bearer ";

    public JwtUtil() {
        this.jwtParser = Jwts.parser().setSigningKey(secret_key);
    }

    /**
     * Creates a JWT token for the authenticated user.
     * Roles are extracted from Spring Security authorities and saved in a 'roles' claim.
     */
    public String createToken(String email, Collection<? extends GrantedAuthority> authorities) {
        Claims claims = Jwts.claims().setSubject(email);

        // Convert GrantedAuthority collection to a List of Strings (e.g., ["ROLE_ADMIN"])
        List<String> roles = authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList());

        claims.put("roles", roles);

        Date tokenCreateTime = new Date();

        // Calculation using SECONDS so that the variable 'accessTokenValidity' is easy to test
        Date tokenValidity = new Date(tokenCreateTime.getTime() + TimeUnit.SECONDS.toMillis(accessTokenValidity));

        return Jwts.builder()
                .setClaims(claims)
                .setExpiration(tokenValidity)
                .signWith(SignatureAlgorithm.HS256, secret_key)
                .compact();
    }

    /**
     * Parses the JWT string to extract the payload (claims).
     */
    private Claims parseJwtClaims(String token) {
        return jwtParser.parseClaimsJws(token).getBody();
    }

    /**
     * Resolves the token from the HTTP Request and parses the claims.
     * Specifically catches ExpiredJwtException to handle session timeout.
     */
    public Claims resolveClaims(HttpServletRequest req) {
        try {
            String token = resolveToken(req);
            if (token != null) {
                return parseJwtClaims(token);
            }
            return null;
        } catch (ExpiredJwtException ex) {
            req.setAttribute("expired", ex.getMessage());
            throw ex; // This is caught by the JwtAuthorizationFilter
        } catch (Exception ex) {
            req.setAttribute("invalid", ex.getMessage());
            throw ex;
        }
    }

    /**
     * Extracts the token string from the "Authorization: Bearer <token>" header.
     */
    public String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader(TOKEN_HEADER);
        if (bearerToken != null && bearerToken.startsWith(TOKEN_PREFIX)) {
            return bearerToken.substring(TOKEN_PREFIX.length());
        }
        return null;
    }

    /**
     * Validates that the token's expiration date is still in the future.
     */
    public boolean validateClaims(Claims claims) throws AuthenticationException {
        try {
            return claims.getExpiration().after(new Date());
        } catch (Exception e) {
            throw e;
        }
    }

    public String getEmail(Claims claims) {
        return claims.getSubject();
    }

    @SuppressWarnings("unchecked")
    private List<String> getRoles(Claims claims) {
        return (List<String>) claims.get("roles");
    }
}
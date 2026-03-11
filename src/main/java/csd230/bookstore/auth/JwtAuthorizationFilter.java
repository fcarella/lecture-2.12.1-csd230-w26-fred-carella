package csd230.bookstore.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class JwtAuthorizationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final ObjectMapper mapper;

    public JwtAuthorizationFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
        this.mapper = new ObjectMapper();
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        try {
            // 1. Extract the token from the Authorization header
            String accessToken = jwtUtil.resolveToken(request);

            // 2. If no token is provided, continue to the next filter
            // (Allows permitAll routes to work or falls back to Form Login)
            if (accessToken == null) {
                filterChain.doFilter(request, response);
                return;
            }

            // 3. Resolve and Validate the JWT Claims
            // If the token is expired, this method throws an ExpiredJwtException
            Claims claims = jwtUtil.resolveClaims(request);

            if (claims != null && jwtUtil.validateClaims(claims)) {
                String email = claims.getSubject();

                // 4. Extract Roles from the JWT Claims
                // This converts the JSON list ["ROLE_ADMIN"] into Spring Security Authorities
                List<String> roles = (List<String>) claims.get("roles");
                List<SimpleGrantedAuthority> authorities = new ArrayList<>();

                if (roles != null) {
                    authorities = roles.stream()
                            .map(SimpleGrantedAuthority::new)
                            .collect(Collectors.toList());
                }

                // 5. Create an Authentication object and set it in the Security Context
                // This tells Spring Boot: "This user is authenticated and has these roles"
                Authentication authentication =
                        new UsernamePasswordAuthenticationToken(email, "", authorities);
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }

        } catch (Exception e) {
            // 6. ERROR HANDLING: This is critical for the React Interceptor
            // If the token is expired or invalid, we return a JSON error response
            Map<String, Object> errorDetails = new HashMap<>();
            errorDetails.put("message", "Authentication Error");
            errorDetails.put("details", e.getMessage());

            // FIX: Explicitly set status to 401 Unauthorized
            // so the Axios interceptor catches it.
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);

            mapper.writeValue(response.getWriter(), errorDetails);

            // Return immediately to stop the rest of the filter chain
            return;
        }

        // Continue the filter chain
        filterChain.doFilter(request, response);
    }
}
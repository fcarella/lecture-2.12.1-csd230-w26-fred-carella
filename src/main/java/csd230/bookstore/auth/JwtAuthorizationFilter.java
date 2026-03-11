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

    // Locally initialized to avoid Bean UnsatisfiedDependencyException during early startup
    private final ObjectMapper mapper = new ObjectMapper();

    public JwtAuthorizationFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        try {
            // 1. Resolve token from Authorization Header (Bearer ...)
            String accessToken = jwtUtil.resolveToken(request);

            // 2. If no token is found, move to the next filter (allows Basic Auth or Form Login to take over)
            if (accessToken == null) {
                filterChain.doFilter(request, response);
                return;
            }

            // 3. Resolve and Validate Claims
            Claims claims = jwtUtil.resolveClaims(request);

            if (claims != null && jwtUtil.validateClaims(claims)) {
                String email = claims.getSubject();

                // 4. Extract Roles from JWT and convert to Spring Security Authorities
                // This is crucial so that .hasRole("ADMIN") works in your config
                List<String> roles = (List<String>) claims.get("roles");
                List<SimpleGrantedAuthority> authorities = new ArrayList<>();

                if (roles != null) {
                    authorities = roles.stream()
                            .map(SimpleGrantedAuthority::new)
                            .collect(Collectors.toList());
                }

                // 5. Create Authentication Token and set it in the Security Context
                Authentication authentication =
                        new UsernamePasswordAuthenticationToken(email, "", authorities);
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }

        } catch (Exception e) {
            // 6. If token is expired or invalid, return a clean JSON error response
            Map<String, Object> errorDetails = new HashMap<>();
            errorDetails.put("message", "Authentication Error");
            errorDetails.put("details", e.getMessage());

            response.setStatus(HttpStatus.FORBIDDEN.value());
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);

            mapper.writeValue(response.getWriter(), errorDetails);
            return; // Stop filter chain execution
        }

        // Continue the filter chain
        filterChain.doFilter(request, response);
    }
}


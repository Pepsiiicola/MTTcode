function draw_circle(x_location,y_location,r)
theta = linspace(0,2*pi);
x = r*cos(theta) + x_location;
y = r*sin(theta) + y_location;
plot(x,y,':k')
end
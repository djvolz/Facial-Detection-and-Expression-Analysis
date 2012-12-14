
% ------------- Mouth detector function ------------------ 
%
%
% Inputs to mouth_detector: mouth_detector(input) takes in an input .jpg file
%
% Outputs of mouth_detector: [numMouthPoints,lineCurvature]
%
% numMouthPoints is the number of detected corner points on each mouth expression
% lineCurvature is the concavity of the date points which is either positive or negative
%
% ---------------------------------------------------------
%  
%   Authors: Justin DeVito, Amanda Meurer, Daniel Volz
%   
%   Rice University, ELEC 301, 2014
%
% ---------------------------------------------------------

function [numMouthPoints,lineCurvature] = mouth_detector(input)

% Create a face detector object
faceDetector = vision.CascadeObjectDetector();

% Read an image and run the face detector 
frame = rgb2ycbcr(imread(input));
box = step(faceDetector, frame);

% Convert the face box to a polygon
xb = box(1); yb = box(2); wb = box(3); hb = box(4);
boxPolygon = int32([xb, yb, xb+wb, yb, xb+wb, yb+hb, xb, yb+hb]);

% Draw the returned box around the detected face.
% shapeInserter  = vision.ShapeInserter('Shape', 'Rectangles', 'BorderColor','Custom','CustomBorderColor',[0 255 0]);

shapeInserter  = vision.ShapeInserter('Shape', 'Polygons', 'BorderColor','Custom','CustomBorderColor',[0 255 0]);
frameB = step(shapeInserter, ycbcr2rgb(frame), boxPolygon);


figure; imshow(frameB); title('Detected Face');


% Mouth
% Create a cascade mouth detector object.
mouthDetector = vision.CascadeObjectDetector('Mouth');

% Cut the video frame into just the face box.
facecrop = imcrop(frame, box);
% Crop to just the mouth region of the face and run mouth detector over this region
mregcrop = imcrop(facecrop, [1 floor(2*box(4)/3) box(3) floor(box(4))]);

mbox = step(mouthDetector, mregcrop);

% Convert the mouth box to a polygon. 
x = mbox(1,1); y = mbox(1,2); w = mbox(1,3); h = mbox(1,4);
mboxPolygon = int32([x, y, x+w, y,x+w,y+h, x, y+h]);

% Crop out just the mouth for analysis
mouthcrop = imcrop(mregcrop, [x y w h]);

% Draw the returned box around the detected face.
shapeInserter = vision.ShapeInserter('Shape', 'Rectangles', 'BorderColor','Custom','CustomBorderColor',[255 0 0]);

% mbvfboxPolygon is the polygon coordinates for putting the mouth box on the video frame
mbvfboxPolygon = int32([x+xb-1, y+yb+floor(2*box(4)/3)-2, w, h]);

frameBB = step(shapeInserter, frameB, mbvfboxPolygon);



figure; imshow(frameBB); title('Detected face and mouth');



% Crop out the region of the image containing the face, and detect the feature points inside it.
cornerDetector = vision.CornerDetector('Method', 'Minimum eigenvalue (Shi & Tomasi)');
points = step(cornerDetector, rgb2gray(mouthcrop));

% Places square marks on mouth
markerInserter = vision.MarkerInserter('Shape', 'Square', 'BorderColor', 'White');
mouthcropp = step(markerInserter, ycbcr2rgb(mouthcrop), points);


figure; imshow(mouthcropp); title('Detected mouth');


% The coordinates of the feature points are with respect to the cropped
% region. They need to be translated back into the original image coordinate system.
points = double(points);
points(:, 1) = points(:, 1) + double(box(1) + mbox(1,1))-2; % -2 compensates for indexing
points(:, 2) = points(:, 2) + double(box(2) + floor(2*box(4)/3) + mbox(1,2))-3; % -3 compensates for indexing

% Display the detected points
markerInserter = vision.MarkerInserter('Shape', 'Square', 'BorderColor', 'White');
frame = step(markerInserter, ycbcr2rgb(frame), int32(points));



figure, imshow(frame), title('Detected features');



% Min and Max of x-axis
minx = min(points(:,1));
maxx = max(points(:,1));

% Interpolated x
XI = minx:1:maxx;

% Number of Points calculation
I = find(points(:,1)==points(end,1) & points(:,2)==points(end,2));
points(I(2:end)',:)=[];
numMouthPoints = length(points(:,1));

%Points that are sorted based on x location
cpoints = sortrows(points,1);


% Goes through x points if multiple at same point they are averaged and
% other points are removed other than averaged point
for xi = minx:1:maxx
    I = find(cpoints(:,1)==xi);
    if length(I)>1
        yI = cpoints(I,2);
        cpoints(I(1),2)=sum(yI)./length(I);
        cpoints(I(2:end),:)=[];
    end
end


% Used for concavity
P = polyfit(cpoints(:,1),cpoints(:,2),2);

% Y values to plot
Y = polyval(P,XI);

lineCurvature = -P(1);

figure
plot(cpoints(:,1),-cpoints(:,2),'k.',XI,-Y,'b','linewidth',2,'markersize',10)
set(gcf,'color','w')
title('Detection of  Curvature')
end
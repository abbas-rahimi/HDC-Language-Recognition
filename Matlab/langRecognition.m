function message = langRecognition
  assignin('base','lookupItemMemeory',@lookupItemMemeory);
  assignin('base','genRandomHV',@genRandomHV);
  assignin('base','cosAngle',@cosAngle);
  assignin('base','computeSumHV', @computeSumHV);
  assignin('base','buildLanguageHV', @buildLanguageHV);
  assignin('base','binarizeHV', @binarizeHV);
  assignin('base','binarizeLanguageHV', @binarizeLanguageHV);
  assignin('base','test', @test); 
  message='Done importing functions to workspace';
end

function randomHV = genRandomHV(D)
    if mod(D,2)
        disp ('Dimension is odd!!');
    else
        randomIndex = randperm (D);
        randomHV (randomIndex(1 : D/2)) = 1;
        randomHV (randomIndex(D/2+1 : D)) = -1;
        %mean (randomHV)
    end
end

function [itemMemory, randomHV] = lookupItemMemeory(itemMemory, key, D)
    if itemMemory.isKey (key) 
        randomHV = itemMemory (key);
        %disp ('found key');
    else
        itemMemory(key) = genRandomHV (D);
        randomHV = itemMemory (key);
    end
end

function cosAngle = cosAngle (u, v)
     cosAngle = dot(u,v)/(norm(u)*norm(v));
end

function [itemMemory, sumHV] = computeSumHV (buffer, itemMemory, N, D)
    %init
    block = zeros (N,D);
    sumHV = zeros (1,D);
    
    for numItems =1:1:length(buffer)
        %read a key
        key = buffer(numItems);

        %while (isletter(char(key)) == 0 && isspace(char(key)) == 0)
        %    numItems = numItems + 1;
        %    key = buffer(numItems);
        %end
        
        %shift read vectors
        block = circshift (block, [1,1]);
        [itemMemory, block(1,:)] = lookupItemMemeory (itemMemory, key, D); 

        %
        if numItems >= N
            nGrams = block(1,:);
            for i = 2:1:N
                nGrams = nGrams .* block(i,:); %element-wise multiplication
            end
            sumHV = sumHV + nGrams;
        end
    end
    
end

function v = binarizeHV (v)
	threshold = 0;
	for i = 1 : 1 : length (v)
		if v (i) > threshold
			v (i) = 1;
		else
			v (i) = -1;
		end
	end
end

function langAM = binarizeLanguageHV (langAM) 
    langLabels = {'afr', 'bul', 'ces', 'dan', 'nld', 'deu', 'eng', 'est', 'fin', 'fra', 'ell', 'hun', 'ita', 'lav', 'lit', 'pol', 'por', 'ron', 'slk', 'slv', 'spa', 'swe'};
    
    for j = 1 : 1 : length (langLabels)
        v = langAM (char(langLabels (j)));
		langAM (char(langLabels (j))) = binarizeHV (v);
    end      
	
end

function [iM, langAM] = buildLanguageHV (N, D) 
    iM = containers.Map;
    langAM = containers.Map;
    langLabels = {'afr', 'bul', 'ces', 'dan', 'nld', 'deu', 'eng', 'est', 'fin', 'fra', 'ell', 'hun', 'ita', 'lav', 'lit', 'pol', 'por', 'ron', 'slk', 'slv', 'spa', 'swe'};
    
    for i = 1:1:length(langLabels)
        fileAddress = strcat('../training_texts/', langLabels (i),'.txt');
        fileID = fopen (char(fileAddress), 'r');
        buffer = fscanf (fileID,'%c');
        fclose (fileID);
        fprintf('Loaded traning language file %s\n',char(fileAddress)); 
        
        [iM, langHV] = computeSumHV (buffer, iM, N, D);
        langAM (char(langLabels (i))) = langHV;
    end        
end

function accuracy = test (iM, langAM, N, D)
	total = 0;
	correct = 0;
	langLabels = {'afr', 'bul', 'ces', 'dan', 'nld', 'deu', 'eng', 'est', 'fin', 'fra', 'ell', 'hun', 'ita', 'lav', 'lit', 'pol', 'por', 'ron', 'slk', 'slv', 'spa', 'swe'};
    langMap = containers.Map;
	langMap ('af') = 'afr';
	langMap ('bg') = 'bul';
	langMap ('cs') = 'ces';
	langMap ('da') = 'dan';
	langMap ('nl') = 'nld';
	langMap ('de') = 'deu';
	langMap ('en') = 'eng';
	langMap ('et') = 'est';
	langMap ('fi') = 'fin';
	langMap ('fr') = 'fra';
	langMap ('el') = 'ell';
	langMap ('hu') = 'hun';
	langMap ('it') = 'ita';
	langMap ('lv') = 'lav';
	langMap ('lt') = 'lit';
	langMap ('pl') = 'pol';
	langMap ('pt') = 'por';
	langMap ('ro') = 'ron';
	langMap ('sk') = 'slk';
	langMap ('sl') = 'slv';
	langMap ('es') = 'spa';
	langMap ('sv') = 'swe';
	
	fileList = dir ('../testing_texts/*.txt');
    for i=1: 1: length(fileList)
		actualLabel = char (fileList(i).name); 
		actualLabel = actualLabel(1:2);
       
		fileAddress = strcat('../testing_texts/', fileList(i).name);
		fileID = fopen (char(fileAddress), 'r');
		buffer = fscanf (fileID, '%c');
		fclose (fileID);
		fprintf ('Loaded testing text file %s\n', char(fileAddress)); 
        
		[iMn, textHV] = computeSumHV (buffer, iM, N, D);
		textHV = binarizeHV (textHV);
		if iM ~= iMn
			fprintf ('\n>>>>>   NEW UNSEEN ITEM IN TEST FILE   <<<<\n');
			exit;
		else
			maxAngle = -1;
			for l = 1:1:length(langLabels)
				angle = cosAngle(langAM (char(langLabels (l))), textHV);
				if (angle > maxAngle)
					maxAngle = angle;
					predicLang = char (langLabels (l));
				end
			end
			if predicLang == langMap(actualLabel)
				correct = correct + 1;
            else
                fprintf ('%s --> %s\n', langMap(actualLabel), predicLang);
			end
			total = total + 1;
		end
    end
    accuracy = correct / total;
end



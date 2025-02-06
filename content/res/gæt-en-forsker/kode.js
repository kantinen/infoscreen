function build_page() {
    var seconds_wait = 5;
    var pixelate_frac = 0.005;
    var unpixelate_factor = 1.1;
    var unpixelate_time_step = 50;
    var n_question_marks = 10;

    var wrapper = d3.select('#wrapper');
    
    function question_marks_generate() {
        var question_marks_data = []
        for (var i = 0; i < n_question_marks; i++) {
            var x = Math.floor(Math.random() * (1920 - 400)) + 100;
            var y = Math.floor(Math.random() * (1080 - 400)) + 100;
            var color = ('hsl(' +
                         Math.floor(Math.random() * 360) + ', ' +
                         (35 + Math.floor(Math.random() * 50)) + '%, ' +
                         (70 + Math.floor(Math.random() * 10)) + '%)');
            question_marks_data.push([x, y, color]);
        }
        return question_marks_data;
    }

    var question_marks = wrapper.append('div');
    question_marks
        .selectAll('p')
        .data(question_marks_generate())
        .enter()
        .append('p')
        .text('?')
        .attr('class', 'background')
        .style('left', function(d) {
            return d[0] + 'px';
        })
        .style('top', function(d) {
            return d[1] + 'px';
        })
        .style('color', function(d) {
            return d[2];
        });

    wrapper.append('h1')
        .text('Gæt en forsker!');
    var text_top = wrapper.append('p');
    text_top.append('span')
        .text('Afsløring om ');
    var counter_element = text_top.append('span')
        .attr('class', 'counter')
        .text(seconds_wait);
    text_top.append('span')
        .text(' sekunder');

    var researchers = [
        'Andrzej Filinski',
        'Boris Düdder',
        'Christian Igel',
        'Cosmin Eugen Oancea',
        'Fritz Henglein',
        'Ivan Luiz Picoli',
        'Jakob Grue Simonsen',
        'Jon Sporring',
        'Jørgen Bansler',
        'Kasper Hornbæk',
        'Ken Friis Larsen',
        'Kenny Erleben',
        'Martin Elsman',
        'Michael Kirkedal Thomsen',
        'Mikkel Thorup',
        'Pernille Bjørn',
        'Philippe Bonnet',
        'Raghavendra Selvan',
        'Stefan Sommer',
        'Stephen Alstrup',
        'Sune Darkner',
        'Torben Ægidius Mogensen',
        'Valkyrie Savage'
    ];
    var researcher = researchers[Math.floor(Math.random() * researchers.length)];

    var img = new Image();
    img.src = ('res/gæt-en-forsker/portrætter/'
               + researcher.replace(/ /g, '_')
               + '.jpg');
    img.addEventListener('load', function() {
        var canvas_height = 700;
        var canvasD3 = wrapper.append('canvas')
            .attr('width', Math.round(img.width * (canvas_height / img.height)))
            .attr('height', canvas_height)
            .style('visibility', 'hidden');
        var canvas = canvasD3[0][0];

        var text_bottom = wrapper.append('p')
            .attr('class', 'bottom')
            .text('Det var ' + researcher + '!!!')
            .style('color', 'rgba(0, 0, 0, 0)');

        var ctx = canvas.getContext('2d');
        // Turn off image smoothing to give the pixelated effect.
        ctx.mozImageSmoothingEnabled = false;
        ctx.webkitImageSmoothingEnabled = false;
        ctx.imageSmoothingEnabled = false;

        function pixelate_portrait(size) {
            var w = canvas.width * size;
            var h = canvas.height * size;

            // First downscale the original image.
            ctx.drawImage(img, 0, 0, w, h);
            
            // Then stretch it.
            ctx.drawImage(canvas, 0, 0, w, h, 0, 0, canvas.width, canvas.height);
        }

        function unpixelate_portrait() {
            pixelate_frac *= unpixelate_factor;
            if (pixelate_frac < 1) {
                pixelate_portrait(pixelate_frac);
                text_bottom.style('color', 'rgba(0, 0, 0, ' + pixelate_frac + ')');
                question_marks.selectAll('p')
                    .style('opacity', 1 - pixelate_frac);
                setTimeout(unpixelate_portrait, unpixelate_time_step);
            }
            else {
                pixelate_portrait(1);
                text_bottom.style('color', 'rgba(0, 0, 0, 1)');
                question_marks.selectAll('p')
                    .style('opacity', 0);
            }
        }

        function countDown() {
            seconds_wait -= 1;
            counter_element.text(seconds_wait);

            question_marks.selectAll('p')
                .data(question_marks_generate())
                .transition()
                .style('left', function(d) {
                    return d[0] + 'px';
                })
                .style('top', function(d) {
                    return d[1] + 'px';
                })
                .style('color', function(d) {
                    return d[2];
                });

            if (seconds_wait <= 0) {
                setTimeout(unpixelate_portrait, unpixelate_time_step);
            }
            else {
                setTimeout(countDown, 1000);
            }
        }

        pixelate_portrait(pixelate_frac);
        canvasD3.style('visibility', 'visible');
        
        setTimeout(countDown, 1000);
    });
}

// Build the entire document.
build_page();

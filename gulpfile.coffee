gulp = require 'gulp'
cleaning = require 'gulp-initial-cleaning'
coffee = require 'gulp-coffee'
plumber = require 'gulp-plumber'
compass = require 'gulp-compass'
prefix = require 'gulp-autoprefixer'
cache = require 'gulp-cached'
symlink = require 'gulp-symlink'
exec = require('child_process').exec
inject = require 'gulp-inject'

DIST = 'dist/'
SRC = 'src/'

cleaning({tasks: ['default'], folders: [DIST]})

# Coffee
SRC_COFFEE = "#{SRC}/**/*.coffee"
gulp.task 'coffee', ->
    gulp.src(SRC_COFFEE)
        .pipe(cache('coffee'))
        .pipe(plumber())
        .pipe(coffee())
        .pipe(gulp.dest(DIST))

# Html
SRC_HTML =  "#{SRC}/**/*.html"
gulp.task 'html', ->
    gulp.src([SRC_HTML, "!#{SRC}/app/index.html"])
        .pipe(gulp.dest(DIST))

# Compass
SRC_COMPASS = "#{SRC}/**/*.sass"
gulp.task 'compass', ->
    gulp.src("#{SRC}/**/main.sass")
        .pipe(plumber())
        .pipe(compass(
            sass: "#{SRC}/ui/sass"
            css: 'tmp/'
        ))
        .pipe(prefix(["last 2 version", "> 5%", "ie 10", "ie 9"]))
        .pipe(gulp.dest(DIST))

# Symlink
gulp.task 'components', ->
  gulp.src('components/', read:false)
    .pipe(symlink(DIST))

# Inject
gulp.task 'inject', ['coffee', 'html'], ->
    gulp.src("#{SRC}/app/index.html")
        .pipe(plumber())
        .pipe(inject(gulp.src([
            'components/angular/angular.js'
            'dist/ui/**/*.js'
            'dist/app/**/*.js'
        ], read: false), {relative: true}))
        .pipe(gulp.dest("#{DIST}/app/"))


gulp.task 'default', ['html', 'components', 'coffee', 'inject', 'compass'], ->
    exec '/Applications/node-webkit.app/Contents/MacOS/node-webkit .', (err, stdout, stderr) ->
        console.log(stdout)
        console.log(stderr)

gulp.task 'look', ['default'], ->
    gulp.watch SRC_COFFEE, ['coffee']
    gulp.watch SRC_HTML, ['inject']
    gulp.watch SRC_COMPASS, ['compass']

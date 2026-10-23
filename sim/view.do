do compile.do
log -r /tb_multicorecpu/*
do wave.do
if {$argc > 0} {
    run $1
} else {
    run -all
}
wave zoom full
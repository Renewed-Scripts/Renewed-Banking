<script>
    import { notify } from "../store/stores";
</script>

<section class="notificaion-container">
    <section class="notificaion-content">
        <i class="start-icon  fa fa-info-circle faa-shake animated fa-2x" />
        <strong class="font__weight-bold" style="font-size:0.69vw;">{$notify}</strong> 
    </section>
</section>

<style>
    .notificaion-container {
        width: 15%;
        box-sizing: border-box;
        padding: 10px 8px;
        margin: 5px 0px;
        position: absolute;
        left: 5%;
        top: 4%;
    }
    .notificaion-content {
        background-color: var(--clr-primary);
        padding: 2rem;
        border-radius: 1rem;
        font-size: 1em;
    }
</style>
